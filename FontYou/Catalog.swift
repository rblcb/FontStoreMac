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

struct CatalogItem: Mappable {
    
    var uid: String
    var date: Int
    var family: String
    var style: String
    var weight: Float?
    var slant: Float?
    var installed: Bool
    var downloadUrl: URL?
    var installedUrl: URL?

    var fontDescriptor: NSFontDescriptor?
    
    init(uid: String, date: Int, family: String, style: String) {
        self.uid = uid
        self.date = date
        self.family = family
        self.style = style
        self.installed = false
    }

    init?(map: Map) {
        uid = ""
        date = 0
        family = ""
        style = ""
        installed = false
    }

    mutating func mapping(map: Map) {
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
    var fonts: [String:CatalogItem] = [:]
    var tree: [String:[CatalogItem]] = [:]
    var lastUpdate: Int?
    
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
                          date: Int,
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
        
        fonts[uid] = item!
        lastUpdate = max(date, lastUpdate ?? 0)
        
        return item!
    }

    // Creates a tree of available fonts based on family name
    
    mutating func updateTree() {
        let allFamilies = fonts.values.filter { $0.installedUrl != nil }.map { $0.family }
        let families = Set<String>(allFamilies)
        
        var tree: [String:[CatalogItem]] = [:]
        for family in families {
            tree[family] = fonts.values.filter { $0.family == family && $0.installedUrl != nil }.sorted { $0.weight! > $1.weight! }
        }
        
        self.tree = tree
        
        NotificationCenter.default.post(name: Notification.Name.init("FontStoreUpdated"), object: nil)
    }
    
    // The primary font is that one that's displayed as the family name. We choose the least slanted that as near as
    // possible to zero in weight
    
    func primaryFont(forFamily family:String) -> CatalogItem? {
        if let family = tree[family] {
            let minSlant = family.reduce(family.first?.slant ?? 0) { return $0 < $1.slant! ? $0 : $1.slant! }
            let leastSlanted = family.filter { return $0.slant! == minSlant }
            let minWeight = leastSlanted.reduce(family.first?.weight! ?? 0) { return abs($0) < abs($1.weight!) ? $0 : $1.weight! }
            let mostRegular = leastSlanted.first { return $0.weight! == minWeight }
            
            return mostRegular
        }
        
        return nil
    }
    
    func saveCatalog() {
        let fileUrl = Catalog.catalogUrl(userId: userId)
        try? self.toJSONString()?.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
    }
    
    static func loadCatalog(userId: String) -> Catalog? {
        let fileUrl = Catalog.catalogUrl(userId: userId)
        do {
            let json = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            if var catalog = Catalog(JSONString: json) {
                
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
                
                catalog.updateTree()
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
