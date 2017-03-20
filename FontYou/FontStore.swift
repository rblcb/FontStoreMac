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

let authEndpoint = "http://localhost:4000/api/desktop/session"
let webSocketEndpoint = "ws://localhost:4000/"

struct AuthDetails {
    let uid: String
    let firstName: String
    let lastName: String
    let accountUrl: URL?
    let settingsUrl: URL?
    let updateUrl: URL?
    let visitUrl: URL?
    let reuseToken: String
}

class FontStore {
    
    static let sharedInstance: FontStore = FontStore()
    
    var authDetails = Property<AuthDetails?>(nil)
    var catalog: Catalog = Catalog()
    
    fileprivate var socket: Socket! = nil
    
    private init() {

        // Try to load the saved catalog
        
        if let savedCatalog = Catalog.loadCatalog() {
            catalog = savedCatalog
        } else {
            devInit()
        }
        
        // Tell the world
        
        NotificationCenter.default.post(name: Notification.Name.init("FontStoreUpdated"), object: nil)
    }
    
    func devInit() {
        
        catalog = Catalog();
        
        guard let fontUrl = Bundle.main.url(forResource: "Fonts", withExtension: nil),
            let enumerator = FileManager.default.enumerator(at: fontUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles], errorHandler: nil)
            else {
                print("Unable to find fonts folder")
                return
        }
        
        while let url = enumerator.nextObject() as? URL {
            catalog.addFonts(fromUrl: url)
        }
        
        catalog.saveCatalog()
    }

    func login(email: String, password: String) {
    
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
                        

                    }
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func logout() {
        self.authDetails.value = nil
    }
}
