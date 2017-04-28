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

let authEndpoint = "http://localhost:4000/session/desktop"
let webSocketEndpoint = "ws://localhost:4000/socket/websocket"

struct AuthDetails: Mappable {
    var uid: String
    var firstName: String
    var lastName: String
    var accountUrl: URL?
    var settingsUrl: URL?
    var updateUrl: URL?
    var visitUrl: URL?
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
         updateUrl: URL?,
         visitUrl: URL?,
         reuseToken: String) {
        
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.accountUrl = accountUrl
        self.updateUrl = updateUrl
        self.visitUrl = visitUrl
        self.reuseToken = reuseToken
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        accountUrl <- (map["accountUrl"], URLTransform(shouldEncodeURLString: false))
        settingsUrl <- (map["settingsUrl"], URLTransform(shouldEncodeURLString: false))
        updateUrl <- (map["updateUrl"], URLTransform(shouldEncodeURLString: false))
        visitUrl <- (map["visitUrl"], URLTransform(shouldEncodeURLString: false))
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
                        let updateUrl = urls["update"],
                        let visitUrl = urls["visit"],
                        let reuseToken = json["reuse_token"] as? String {
                        
                        self.authDetails.value = AuthDetails(uid: uid,
                                                             firstName: firstName,
                                                             lastName: lastName,
                                                             accountUrl: URL(string: accountUrl),
                                                             settingsUrl: URL(string: settingsUrl),
                                                             updateUrl: URL(string: updateUrl),
                                                             visitUrl: URL(string: visitUrl),
                                                             reuseToken: reuseToken)
                        
                        // Remember if required
                        
                        if rememberMe {
                            try? self.authDetails.value?.toJSONString()?.write(to: self.preferencesUrl(), atomically: true, encoding: String.Encoding.utf8)
                        }
                        
                        self.completeLogin()
                    }
                    
                case .failure(let error):
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
                    if let fontUrl = item.installedUrl, item.installed {
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
        
        status.value = "Connecting to server"
        
        socket = Socket(url: URL(string: webSocketEndpoint)!, params: ["reuse_token" : authDetails.value!.reuseToken])
        socket.enableLogging = true
        
        socket.onConnect = {
            
            let catalogChannel = self.socket.channel("catalog")
            let userChannel = self.socket.channel("users:\(self.authDetails.value!.uid)")
            
            self.status.value = "Updating catalog..."
            
            // Catalog channel events
            
            catalogChannel.on("font:description") { message in
                if let data = message.payload as? [String:String] {
                    
                    // Note that we add items *before* they are downloaded. This allows to save the catalog as the
                    // downloads proceed. In the event of en error or disconnection, the next request to the server won't
                    // include the fonts that we've already been told about, but that won't matter since they'll still be stored in
                    // the catalog awaiting download

                    let item = self.catalog.value!.addFont(uid: data["uid"]!,
                                                           date: Double(data["created_at"]!)!,
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
                    
                    if let url = item.installedUrl {
                        try? FileManager.default.removeItem(at: url)
                    }
                    
                    self.catalog.value?.remove(uid: uid)
                }
            }
            
            catalogChannel.on("update:complete") { _ in
                
                // Once the font list is up-to-date we join the user channel
                
                userChannel.join()
                let payload: Socket.Payload = self.catalog.value?.lastUserUpdate != nil ? ["last_update_date": self.catalog.value!.lastUserUpdate!] : [:]
                userChannel.send("update:request", payload: payload)
            }
            
            // User channel events
            
            userChannel.on("font:activation") { message in
                if let data = message.payload as? [String:String] {
                    self.installFont(uid: data["uid"]!, installed: true)
                }
            }
            
            userChannel.on("font:deactivation") { message in
                if let data = message.payload as? [String:String] {
                    self.installFont(uid: data["uid"]!, installed: false)
                }
            }
            
            userChannel.on("update:complete") { _ in
                self.status.value = nil
            }
            
            catalogChannel.join()
            let payload: Socket.Payload = self.catalog.value?.lastCatalogUpdate != nil ? ["last_update_date": self.catalog.value!.lastCatalogUpdate!] : [:]
            catalogChannel.send("update:request", payload: payload)
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
            if item.installedUrl == nil {
                self.downloadFont(item: item)
            }
        }
    }
    
    func downloadFont(item: CatalogItem) {
        guard let downloadUrl = item.downloadUrl else { return }
        guard item.installedUrl == nil else { return }
        
        downloadQueue.addOperation {
            
            print("Downloading \(item.style)")
            
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
                guard FontUtility.activateFontFile(fontUrl, with: .process) else { return }
                guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(fontUrl as CFURL) as? [NSFontDescriptor] else { return }
                let desc = descriptors.first!
                
                let downloadItem = item
                let traits = desc.object(forKey: NSFontTraitsAttribute) as? NSDictionary
                downloadItem.weight = traits?["NSCTFontWeightTrait"] as? Float ?? 0.0
                downloadItem.slant = traits?["NSCTFontSlantTrait"] as? Float ?? 0.0
                downloadItem.installedUrl = fontUrl
                downloadItem.fontDescriptor = desc
                
                // Update the catalog synchronously so that multiple download queues don't try to manipulate
                // it at the same time.
                
                DispatchQueue.main.sync {                    
                    self.catalog.value?.update(item: downloadItem)
                }
            }
        }
    }
    
    func installFont(uid: String, installed: Bool) {
        guard let item = catalog.value?.fonts[uid] else { return }
        
        if (item.installedUrl != nil) {
            if installed {
                FontUtility.activateFontFile(item.installedUrl, with: .user)
                
            } else {
                FontUtility.deactivateFontFile(item.installedUrl, with: .user)
            }
        }
        
        item.installed = installed
        catalog.value!.update(item: item)
    }

    func toggleInstall(uid: String) {
        guard let item = catalog.value?.fonts[uid] else { return }
        installFont(uid: uid, installed: !item.installed)
    }
}
