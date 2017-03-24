//
//  Catalogue.swift
//  FontYou
//
//  Created by Timothy Armes on 20/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Foundation
import CoreText
import Cocoa
import ObjectMapper
import Alamofire
import ReactiveKit
import Bond

let transformURLIfExists = TransformOf<URL, Any?>(
    fromJSON: { (value: Any?) -> URL? in
        guard let urlString = value as? String else { return nil }
        guard let url = URL(string: urlString) else { return nil }
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
},
    toJSON: { (value: URL?) -> String? in
        if let URL = value {
            return URL.absoluteString
        }
        return nil
})

// This should really be struct, not a class, but since we're directly displaying these items
// in the NSOutlineView then we have no choice, otherwise rowForItem fails to work.

class CatalogItem: Mappable {
    
    var uid: String
    var date: Double
    var family: String
    var style: String
    var weight: Float?
    var slant: Float?
    var installed: Bool
    var downloadUrl: URL?
    var installedUrl: URL?

    var fontDescriptor: NSFontDescriptor?
    
    init(uid: String, date: Double, family: String, style: String) {
        self.uid = uid
        self.date = date
        self.family = family
        self.style = style
        self.installed = false
    }

    required init?(map: Map) {
        uid = ""
        date = 0
        family = ""
        style = ""
        installed = false
    }

    func mapping(map: Map) {
        uid <- map["uid"]
        date <- map["date"]
        family <- map["family"]
        style <- map["style"]
        weight <- map["weight"]
        slant <- map["slant"]
        installed <- map["installed"]
        downloadUrl <- (map["downloadUrl"], URLTransform(shouldEncodeURLString: false))
        installedUrl <- (map["installedUrl"], transformURLIfExists)
    }
}

struct Catalog: Mappable {
    
    var userId: String
    var fonts = MutableObservableDictionary<String, CatalogItem>([:])
    var lastUpdate: Double?
    
    init?(map: Map) {
        self.userId = ""
    }
    
    init(userId: String) {
        self.userId = userId
    }
 
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        fonts <- map["fonts"]
        lastUpdate <- map["lastUpdate"]
    }
    
    @discardableResult
    mutating func addFont(uid: String,
                          date: Double,
                          familyName: String,
                          style: String,
                          weight: Float? = nil,
                          slant: Float? = nil,
                          downloadUrl: URL? = nil,
                          installedUrl: URL? = nil,
                          fontDescriptor: NSFontDescriptor? = nil) -> CatalogItem {
        
        // Try to find this item in the catalog
        
        var item: CatalogItem? = fonts[uid]
        
        if item != nil {
            if item!.date != date {
                // We have it, but the date's changed, so we need to download it again
                
                item!.downloadUrl = downloadUrl
                item!.installedUrl = nil
            } else {
                // We have it already, just return
                return item!
            }
        } else {
            // We don't have this item in the catalog - we need to add it
            item = CatalogItem(uid: uid, date: date, family: familyName, style: style)
            item!.weight = weight
            item!.slant = slant
            item!.downloadUrl = downloadUrl
            item!.installedUrl = installedUrl
            item!.fontDescriptor = fontDescriptor
        }
        
        // Update the catalog. 
        
        print(item?.style)
        fonts[uid] = item!
        lastUpdate = max(date, lastUpdate ?? 0)
        
        return item!
    }
    
    mutating func update(item: CatalogItem) {
        
        // Update the catalog
        
        fonts[item.uid] = item
        saveCatalog()
    }
    
    mutating func remove(uid: String) {
        
        // Update the catalog
        
        fonts.removeValue(forKey: uid)
        saveCatalog()
    }
    
    func saveCatalog() {
        let fileUrl = Catalog.catalogUrl(userId: userId)
        try? self.toJSONString()?.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
    }
    
    static func loadCatalog(userId: String) -> Catalog? {
        let fileUrl = Catalog.catalogUrl(userId: userId)
        do {
            let json = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            if let catalog = Catalog(JSONString: json) {
                
                // Try to activate each for for use in the application
                
                for (uid, item) in catalog.fonts {
                    guard item.installedUrl != nil else { continue }
                    guard FontUtility.activateFontFile(item.installedUrl, with: .process) else { print("Unable to activate \(item.family).\(item.style)"); continue; }
                    if let desc = (CTFontManagerCreateFontDescriptorsFromURL(item.installedUrl as! CFURL) as? [NSFontDescriptor])?.first {
                        catalog.fonts[uid]!.fontDescriptor = desc
                    } else {
                        print("Unable to create descriptors for \(item.family).\(item.style)")
                    }
                }
                
                return catalog
            
            } else {
                return nil
            }
        }
        catch {
            return nil
        }
    }
    
    static func appSupportUrl() -> URL {
        let dir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .allDomainsMask, true).first!
        let folderUrl = URL(fileURLWithPath: dir).appendingPathComponent("FontStore")
        if !FileManager.default.fileExists(atPath: folderUrl.absoluteString) {
            try? FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        return folderUrl
    }
    
    static func catalogUrl(userId: String) -> URL {
        let asUrl = appSupportUrl()
        return asUrl.appendingPathComponent("\(userId).json")
    }
    
    static func fontsUrl() -> URL {
        let asUrl = appSupportUrl()
        return asUrl.appendingPathComponent("fonts", isDirectory: true)
    }
}
