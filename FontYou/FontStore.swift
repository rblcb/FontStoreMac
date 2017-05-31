//
//  FontStore.swift
//  FontYou
//
//  Created by Timothy Armes on 13/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Foundation
import CoreText
import Cocoa
import Alamofire
import ReactiveKit
import ObjectMapper

//let authEndpoint = "http://localhost:4000/session/desktop"
//let webSocketEndpoint = "ws://localhost:4000/socket/websocket"
let authEndpoint = "https://api.staging.fontstore.com/session/desktop"
let webSocketEndpoint = "wss://api.staging.fontstore.com/socket/websocket"

struct AuthDetails: Mappable {
    var uid: String
    var firstName: String
    var lastName: String
    var accountUrl: URL?
    var settingsUrl: URL?
    var reuseToken: String

    init?(map: Map) {
        uid = ""
        firstName = ""
        lastName = ""
        reuseToken = ""
    }
    
    init(uid: String,
         firstName: String,
         lastName: String,
         accountUrl: URL?,
         settingsUrl: URL?,
         reuseToken: String) {
        
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.accountUrl = accountUrl
        self.settingsUrl = settingsUrl
        self.reuseToken = reuseToken
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        accountUrl <- (map["accountUrl"], URLTransform(shouldEncodeURLString: false))
        settingsUrl <- (map["settingsUrl"], URLTransform(shouldEncodeURLString: false))
        reuseToken <- map["reuseToken"]

    }
}

class FontStore {
    
    static let sharedInstance: FontStore = FontStore()
    
    var authDetails = Property<AuthDetails?>(nil)
    var catalog = Property<Catalog?>(nil)
    var status = Property<String?>(nil)
    let downloadQueue = OperationQueue()
    
    fileprivate var socket: Socket! = nil
    fileprivate var userChannel: Channel? = nil
    
    private init() {

        // Create a download queue that will download up to 3 fonts at a time, as per the spec
        downloadQueue.maxConcurrentOperationCount = 3
    }
    
    func login(email: String, password: String, rememberMe: Bool) {
    
        let osv = ProcessInfo.processInfo.operatingSystemVersion
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        let parameters = [
            "login": email,
            "password": password,
            "protocol_version": "1.0.0",
            "application_version": appVersion,
            "os": "Mac",
            "os_version": "\(osv.majorVersion).\(osv.minorVersion).\(osv.patchVersion)"
        ]
        
        status.value = "Connecting to server"
        
        Alamofire.request(authEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate().responseJSON { response in
                switch response.result {
                case .success:
                    guard let json = response.result.value as? [String: Any] else { return }
                    guard let urls = json["urls"] as? [String: String] else { return }

                    if let uid = json["uid"] as? String,
                        let firstName = json["first_name"] as? String,
                        let lastName = json["last_name"] as? String,
                        let accountUrl = urls["account"],
                        let settingsUrl = urls["settings"],
                        let reuseToken = json["reusable_token"] as? String {
                        
                        self.authDetails.value = AuthDetails(uid: uid,
                                                             firstName: firstName,
                                                             lastName: lastName,
                                                             accountUrl: URL(string: accountUrl),
                                                             settingsUrl: URL(string: settingsUrl),
                                                             reuseToken: reuseToken)
                        
                        // Remember if required
                        
                        if rememberMe {
                            try? self.authDetails.value?.toJSONString()?.write(to: self.preferencesUrl(), atomically: true, encoding: String.Encoding.utf8)
                        }
                        
                        self.completeLogin()
                    }
                    
                case .failure(let error):
                    self.status.value = nil
                    print(error)
                }
        }
    }
    
    func logonUsingStoredDetails() {
        do {
            let json = try String(contentsOf: preferencesUrl(), encoding: String.Encoding.utf8)
            if let authDetails = AuthDetails(JSONString: json) {
                self.authDetails.value = authDetails
                self.completeLogin()
            }
        }
        catch {
        }
    }
    
    func completeLogin() {
        
        if let uid = authDetails.value?.uid {
            
            // Try to load the saved catalog
            
            if let savedCatalog = Catalog.loadCatalog(userId: uid) {
                self.catalog.value = savedCatalog
            } else {
                self.catalog.value = Catalog(userId: uid)
            }
            
            // Start downloading fonts that we didn't finish downloading last time
            
            self.downloadFonts()
            
            // Create the web socket
            
            self.connectWebSocket()
        }
    }
    
    func logout() {
        self.authDetails.value = nil
        socket?.disconnect()
        socket = nil
        
        status.value = nil
        
        try? FileManager.default.removeItem(at: preferencesUrl())
        
        downloadQueue.cancelAllOperations()
        
        // Disactivate fonts
        
        if let catalog = catalog.value {
            DispatchQueue.global().async {
                for (_, item) in catalog.fonts {
                    if let fontUrl = item.encryptedUrl, item.installed {
                        FontUtility.deactivateFontFile(fontUrl, with: .user)
                    }
                }
            }
        }
        
        catalog.value = nil
    }
    
    func preferencesUrl() -> URL {
        let dir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .allDomainsMask, true).first!
        return URL(fileURLWithPath: dir).appendingPathComponent("Preferences/com.fontstore.logon.json")
    }
    
    func connectWebSocket() {
        
        self.status.value = "Updating catalog..."
        
        socket = Socket(url: URL(string: webSocketEndpoint)!, params: ["reusable_token" : authDetails.value!.reuseToken])
        socket.enableLogging = true
        
        socket.onConnect = {
            
            let catalogChannel = self.socket.channel("catalog")
            self.userChannel = self.socket.channel("users:\(self.authDetails.value!.uid)")
            
            // Catalog channel events
            
            catalogChannel.on("fonts-package") { _ in
                self.catalog.value!.semaphore.wait()
                defer { self.catalog.value!.semaphore.signal() }
                for (_, item) in self.catalog.value!.fonts {
                    item.isNew = false
                    self.catalog.value!.update(item: item)
                }
            }
            
            catalogChannel.on("font:description") { message in
                if let data = message.payload as? [String:String] {
                    
                    // Note that we add items *before* they are downloaded. This allows to save the catalog as the
                    // downloads proceed. In the event of en error or disconnection, the next request to the server won't
                    // include the fonts that we've already been told about, but that won't matter since they'll still be stored in
                    // the catalog awaiting download

                    self.catalog.value!.semaphore.wait()
                    defer { self.catalog.value!.semaphore.signal() }

                    let item = self.catalog.value!.addFont(uid: data["uid"]!,
                                                           familyName: data["font_family"]!,
                                                           style: data["font_style"]!,
                                                           downloadUrl: URL(string: data["download_url"]!)!)
                    
                    self.downloadFont(item: item)
                }
            }
            
            catalogChannel.on("font:deletion") { message in
                
                if let data = message.payload as? [String:String],
                    let uid = data["uid"],
                    let item = self.catalog.value?.fonts[uid] {
                    
                    if let url = item.encryptedUrl {
                        try? FileManager.default.removeItem(at: url)
                    }
                    
                    self.catalog.value!.semaphore.wait()
                    defer { self.catalog.value!.semaphore.signal() }

                    self.catalog.value?.remove(uid: uid)
                }
            }
            
            catalogChannel.on("update:complete") { message in
                
                if let data = message.payload as? [String:String] {
                    self.catalog.value!.lastCatalogUpdate = max(Double(data["transmitted_at"]!)!, self.catalog.value!.lastCatalogUpdate ?? 0)
                    
                    // Once the font list is up-to-date we join the user channel
                    
                    self.userChannel!.join()?.receive("ok") { _ in
                        var payload:Socket.Payload = [:]
                        if let date = self.catalog.value?.lastUserUpdate {
                            payload = ["last_update_date": String(format: "%.0f", date)]
                        }
                        
                        self.catalog.value!.saveCatalog()
                        self.userChannel!.send("update:request", payload: payload)
                    }
                }
            }
            
            // User channel events
            
            self.userChannel!.on("font:activation") { message in
                if let data = message.payload as? [String:String] {
                    self.installFont(uid: data["uid"]!, installed: true)
                }
            }
            
            self.userChannel!.on("font:deactivation") { message in
                if let data = message.payload as? [String:String] {
                    self.installFont(uid: data["uid"]!, installed: false)
                }
            }
            
            self.userChannel!.on("update:complete") { message in
                if let data = message.payload as? [String:String] {
                    self.catalog.value!.lastUserUpdate = max(Double(data["transmitted_at"]!)!, self.catalog.value!.lastUserUpdate ?? 0)
                    self.catalog.value!.saveCatalog()
                    self.status.value = nil
                }
            }
            
            catalogChannel.join()?.receive("ok") { _ in
                var payload:Socket.Payload = [:]
                if let date = self.catalog.value?.lastCatalogUpdate {
                    payload = ["last_update_date": String(format: "%.0f", date)]
                }
                catalogChannel.send("update:request", payload: payload)
            }
        }
        
        socket.onDisconnect = { error in
            
            if self.authDetails.value != nil {
                
                // If we still have authentication details then this wasn't a logout - we've simply lost connection
                // We just keep trying to reconnect...
                
                self.downloadQueue.cancelAllOperations()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) { self.socket.connect() }
                
                self.status.value = "Connecting to server..."
            }
        }
        
        // Try to connect
        
        socket.connect()
    }
    
    func downloadFonts() {
        
        // Find all the fonts which haven't yet been downloaded
        
        for (_, item) in catalog.value!.fonts {
            if item.encryptedUrl == nil {
                self.downloadFont(item: item)
            }
        }
    }
    
    func downloadFont(item: CatalogItem) {
        guard let downloadUrl = item.downloadUrl else { return }
        guard item.encryptedUrl == nil else { return }
        
        downloadQueue.addOperation {
            
            print("Downloading \(item.family) \(item.style)")
            
            // Function to return the destination path
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var fileURL = Catalog.fontsUrl()
                fileURL.appendPathComponent(item.uid)
                fileURL.appendPathExtension(downloadUrl.pathExtension)
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            // Download "synchronously" within this task so that we don't return before we've finished
            // downloading. This ensures that the downloadQueue remains full until the task is truly finished.
            
            let semaphore = DispatchSemaphore(value: 0)
            var result: DefaultDownloadResponse!
            
            Alamofire.download(downloadUrl, to: destination).response { response in
                result = response
                semaphore.signal()
            }
            
            _ = semaphore.wait()
            
            // Downloading complete, get the font's characteristics
            
            if result.error == nil, let fontUrl = result.destinationURL {
                
                item.encryptedUrl = fontUrl
                let data = item.decryptedData
                
                guard let font = FontUtility.createCGFont(from: data) else { print("Unable to create font from data for \(item.family).\(item.style)"); return; }
                guard FontUtility.activate(font) else { print("Unable to activate \(item.family).\(item.style)"); return; }
                if let desc:NSFontDescriptor = CTFontManagerCreateFontDescriptorFromData(data! as CFData) {
                    let downloadItem = item
                    let traits = desc.object(forKey: NSFontTraitsAttribute) as? NSDictionary
                    downloadItem.weight = traits?["NSCTFontWeightTrait"] as? Float ?? 0.0
                    downloadItem.slant = traits?["NSCTFontSlantTrait"] as? Float ?? 0.0
                    downloadItem.encryptedUrl = fontUrl
                    downloadItem.fontDescriptor = desc
                    
                    // Update the catalog synchronously so that multiple download queues don't try to manipulate
                    // it at the same time.
                    
                    self.catalog.value!.semaphore.wait()
                    let oldItem = self.catalog.value!.fonts[item.uid]
                    self.catalog.value?.update(item: downloadItem)
                    self.catalog.value!.semaphore.signal()
                    
                    // If the item had been marked as installed while it was downloading, then we
                    // install it now.
                    
                    if oldItem?.installed == true {
                        self.installFont(uid: item.uid, installed: true)
                    }
                    
                } else {
                    print("Unable to create descriptors for \(item.family).\(item.style)")
                }
            }
        }
    }
    
    func requestFontInstall(uid: String, installed: Bool) {
        guard let userChannel = userChannel else { return }
        let payload: Socket.Payload = ["uid": uid]
        if installed {
            userChannel.send("font:activation-request", payload: payload)
        } else {
            userChannel.send("font:deactivation-request", payload: payload)
        }
    }
    
    func toggleInstall(uid: String) {
        guard let item = catalog.value?.fonts[uid] else { return }
        requestFontInstall(uid: uid, installed: !item.installed)
    }
    
    func installFont(uid: String, installed: Bool) {
        catalog.value!.semaphore.wait()
        defer {  catalog.value!.semaphore.signal() }
        
        guard let item = catalog.value?.fonts[uid] else { return }
        
        // Do this synchrounously so that we don't try to update items from several places at once (such
        // as the download finishing as we try to install)
        
        print("Installing  \(item.family) \(item.style)")
        
        if (item.encryptedUrl != nil) {
            if installed {
                let data = item.decryptedData
                let installedUrl = Catalog.installedUrl().appendingPathComponent(item.uid)
                try? FileManager.default.removeItem(at: installedUrl)
                
                do {
                    try data!.write(to: installedUrl, options: .atomicWrite)
                    item.installedUrl = installedUrl
                    FontUtility.activateFontFile(item.installedUrl, with: .user)
                }
                catch {
                    print("Unable to write to \(installedUrl)")
                }
                
            } else {
                if let installedUrl = item.installedUrl {
                    FontUtility.deactivateFontFile(installedUrl, with: .user)
                    try? FileManager.default.removeItem(at: installedUrl)
                    item.installedUrl = nil
                }
            }
        }
        
        item.installed = installed
        catalog.value!.update(item: item)
    }
}
