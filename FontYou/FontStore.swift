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

let endpoint = "http://localhost:4000/api/desktop/session"

struct AuthDetails {
    let firstName: String
    let lastName: String
    let accountUrl: NSURL?
    let settingsUrl: NSURL?
    let updateUrl: NSURL?
    let visitUrl: NSURL?
    let reuseToken: String
}

struct FontStoreItem {
    let name: String
    let fontDescriptor: NSFontDescriptor
    let weight: Float
    let slant: Float
    let installed: Bool
}

class FontStore {
    
    static let sharedInstance: FontStore = FontStore()
    static var families: [String:[FontStoreItem]] = [:]
    
    var authDetails = Property<AuthDetails?>(nil)
    
    private init() {
        guard let fontUrl = Bundle.main.url(forResource: "Fonts", withExtension: nil),
            let enumerator = FileManager.default.enumerator(at: fontUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles], errorHandler: nil)
            else {
                print("Unable to find fonts folder")
                return
        }
        
        // Activate each font for this application, so that we can display it in the menu
        
        while let url = enumerator.nextObject() as? URL {
            if FontUtility.activateFontFile(url, with: .process) {
                if let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [NSFontDescriptor] {
                    for desc in descriptors {
                        if let font = NSFont.init(descriptor: desc, size: 16),
                           let familyName = font.familyName {
                            let traits = desc.object(forKey: NSFontTraitsAttribute) as? NSDictionary
                            let weight = traits?["NSCTFontWeightTrait"] as? Float ?? 0.0
                            let slant = traits?["NSCTFontSlantTrait"] as? Float ?? 0.0
                            let item = FontStoreItem(name: font.fontName, fontDescriptor: desc, weight: weight, slant: slant, installed: false)
                            var family = FontStore.families[familyName] ?? []
                            family.append(item)
                            FontStore.families[familyName] = family
                        }
                    }
                }
            }
        }
        
        // Sort the fonts in each family by weight
        
        for familyName in FontStore.families.keys {
            FontStore.families[familyName] = FontStore.families[familyName]!.sorted { $0.weight > $1.weight }
        }
        
        // Tell the world
        
        NotificationCenter.default.post(name: Notification.Name.init("FontStoreUpdated"), object: nil)
    }
    
    // The primary font is that one that's displayed as the family name. We choose the least slanted that as near as
    // possible to zero in weight
    
    func primaryFont(forFamily family:String) -> FontStoreItem? {
        if let family = FontStore.families[family] {
            let minSlant = family.reduce(family.first?.slant ?? 0) { return $0 < $1.slant ? $0 : $1.slant }
            let leastSlanted = family.filter { return $0.slant == minSlant }
            let minWeight = leastSlanted.reduce(family.first?.weight ?? 0) { return abs($0) < abs($1.weight) ? $0 : $1.weight }
            let mostRegular = leastSlanted.first { return $0.weight == minWeight }
            
            return mostRegular
        }
        
        return nil
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
        
        Alamofire.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate().responseJSON { response in
                switch response.result {
                case .success:
                    guard let json = response.result.value as? [String: Any] else { return }
                    guard let urls = json["urls"] as? [String: String] else { return }

                    if let firstName = json["first_name"] as? String,
                        let lastName = json["last_name"] as? String,
                        let accountUrl = urls["account"],
                        let settingsUrl = urls["settings"],
                        let updateUrl = urls["update"],
                        let visitUrl = urls["visit"],
                        let reuseToken = json["reuse_token"] as? String {
                        
                        self.authDetails.value = AuthDetails(firstName: firstName,
                                                        lastName: lastName,
                                                        accountUrl: NSURL(string: accountUrl),
                                                        settingsUrl: NSURL(string: settingsUrl),
                                                        updateUrl: NSURL(string: updateUrl),
                                                        visitUrl: NSURL(string: visitUrl),
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
