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

struct CatalogItem: Mappable {
    
    var name: String
    var weight: Float
    var slant: Float
    var installed: Bool
    var fontDescriptor: NSFontDescriptor?
    var downloadUrl: URL?
    var url: URL?
    
    init(name: String, weight: Float, slant: Float, installed: Bool) {
        self.name = name
        self.weight = weight
        self.slant = slant
        self.installed = installed
    }

    init?(map: Map) {
        name = ""
        weight = 0
        slant = 0
        installed = false
    }

    mutating func mapping(map: Map) {
        name <- map["name"]
        weight <- map["weight"]
        slant <- map["slant"]
        installed <- map["installed"]
        downloadUrl <- (map["downloadUrl"], URLTransform())
        url <- (map["url"], URLTransform(shouldEncodeURLString: false))
    }
}

struct Catalog: Mappable {
    
    var families: [String:[CatalogItem]] = [:]
    var lastUpdate: Date?
    
    init?(map: Map) {
    }
    
    init() {
    }
 
    mutating func mapping(map: Map) {
        families <- map["families"]
        lastUpdate <- (map["lastUpdate"], DateTransform())
    }
    
    mutating func addFonts(fromUrl url: URL) {
    
        // Activate each font for this application, so that we can display it in the menu
        
        guard FontUtility.activateFontFile(url, with: .process) else { return }
        guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [NSFontDescriptor] else { return }
        
        // Add the font to the catalogue
        
        for desc in descriptors {
            if let font = NSFont.init(descriptor: desc, size: 16),
                let familyName = font.familyName {
                let traits = desc.object(forKey: NSFontTraitsAttribute) as? NSDictionary
                let weight = traits?["NSCTFontWeightTrait"] as? Float ?? 0.0
                let slant = traits?["NSCTFontSlantTrait"] as? Float ?? 0.0
                var item = CatalogItem(name: font.fontName, weight: weight, slant: slant, installed: false)
                
                item.fontDescriptor = desc
                item.url = url
                
                var family = families[familyName] ?? []
                family.append(item)
                families[familyName] = family
                
                // Sort the fonts in each family by weight
                
                families[familyName] = families[familyName]!.sorted { $0.weight > $1.weight }
            }
        }
    }
    
    
    // The primary font is that one that's displayed as the family name. We choose the least slanted that as near as
    // possible to zero in weight
    
    func primaryFont(forFamily family:String) -> CatalogItem? {
        if let family = families[family] {
            let minSlant = family.reduce(family.first?.slant ?? 0) { return $0 < $1.slant ? $0 : $1.slant }
            let leastSlanted = family.filter { return $0.slant == minSlant }
            let minWeight = leastSlanted.reduce(family.first?.weight ?? 0) { return abs($0) < abs($1.weight) ? $0 : $1.weight }
            let mostRegular = leastSlanted.first { return $0.weight == minWeight }
            
            return mostRegular
        }
        
        return nil
    }
    
    func saveCatalog() {
        let fileUrl = Catalog.catalogUrl()
        try? self.toJSONString()?.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
    }
    
    static func loadCatalog() -> Catalog? {
        let fileUrl = Catalog.catalogUrl()
        do {
            let json = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            if var catalog = Catalog(JSONString: json) {
                
                // Try to activate each for for use in the application
                
                for (familyName, var items) in catalog.families {
                    for (index, var item) in items.enumerated() {
                        guard FontUtility.activateFontFile(item.url, with: .process) else { print("Unable to activate \(familyName).\(item.name)"); continue; }
                        if let desc = (CTFontManagerCreateFontDescriptorsFromURL(item.url as! CFURL) as? [NSFontDescriptor])?.first {
                            item.fontDescriptor = desc
                            catalog.families[familyName]?[index].fontDescriptor = desc
                        } else {
                            print("Unable to create descriptors for \(familyName).\(item.name)")
                        }
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
    
    static func catalogUrl() -> URL {
        let dir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .allDomainsMask, true).first!
        let folderUrl = URL(fileURLWithPath: dir).appendingPathComponent("FontStore")
        let fileUrl = folderUrl.appendingPathComponent("catalog.json")
        if !FileManager.default.fileExists(atPath: folderUrl.absoluteString) {
            try? FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        return fileUrl
    }
}
