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

// Create a download queue that will download up to 3 fonts at a time, as per the spec
let downloadQueue = MaxConcurrentTasksQueue(withMaxConcurrency: 3)

struct CatalogItem: Mappable {
    
    var uid: String
    var style: String
    var weight: Float
    var slant: Float
    var installed: Bool
    var fontDescriptor: NSFontDescriptor?
    var downloadUrl: URL?
    var url: URL?
    
    init(uid: String, style: String, weight: Float, slant: Float, installed: Bool) {
        self.uid = uid
        self.style = style
        self.weight = weight
        self.slant = slant
        self.installed = installed
    }

    init?(map: Map) {
        uid = ""
        style = ""
        weight = 0
        slant = 0
        installed = false
    }

    mutating func mapping(map: Map) {
        uid <- map["uid"]
        style <- map["style"]
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
    
    mutating func addFont(uid: String, familyName: String, style: String, downloadUrl: URL) {
        
        // Add a download request to the queue
        
        downloadQueue.enqueue {
            
            // Function to return the destination path
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var fileURL = Catalog.fontsUrl(family: familyName)
                fileURL.appendPathComponent(downloadUrl.lastPathComponent)
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
                
                let traits = desc.object(forKey: NSFontTraitsAttribute) as? NSDictionary
                let weight = traits?["NSCTFontWeightTrait"] as? Float ?? 0.0
                let slant = traits?["NSCTFontSlantTrait"] as? Float ?? 0.0
                
                var item = CatalogItem(uid: uid, style: style, weight: weight, slant: slant, installed: false)
                item.fontDescriptor = desc
                item.url = fontUrl
                
                // Add the item to the catalog synchronously so that multiple download queues don't try to manipulate
                // it at the same time.
                
                DispatchQueue.main.sync {
                    var family = self.families[familyName] ?? []
                    family.append(item)
                    self.families[familyName] = family
                
                    // Sort the fonts in each family by weight
                
                    self.families[familyName] = self.families[familyName]!.sorted { $0.weight > $1.weight }
                
                    // Save the db and update the interface
                
                    self.saveCatalog()
                    NotificationCenter.default.post(name: Notification.Name.init("FontStoreUpdated"), object: nil)
                }
            }
        }
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
                var item = CatalogItem(uid: "", style: font.fontName, weight: weight, slant: slant, installed: false)
                
                item.fontDescriptor = desc
                item.url = url
                
                var family = families[familyName] ?? []
                family.append(item)
                families[familyName] = family
                
                // Sort the fonts in each family by weight
                
                families[familyName] = families[familyName]!.sorted { $0.weight > $1.weight }
            }
        }
        
        // Tell the world
        
        NotificationCenter.default.post(name: Notification.Name.init("FontStoreUpdated"), object: nil)
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
                
                for (familyName, items) in catalog.families {
                    for (index, var item) in items.enumerated() {
                        guard FontUtility.activateFontFile(item.url, with: .process) else { print("Unable to activate \(familyName).\(item.style)"); continue; }
                        if let desc = (CTFontManagerCreateFontDescriptorsFromURL(item.url as! CFURL) as? [NSFontDescriptor])?.first {
                            item.fontDescriptor = desc
                            catalog.families[familyName]?[index].fontDescriptor = desc
                        } else {
                            print("Unable to create descriptors for \(familyName).\(item.style)")
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
    
    static func appSupportUrl() -> URL {
        let dir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .allDomainsMask, true).first!
        let folderUrl = URL(fileURLWithPath: dir).appendingPathComponent("FontStore")
        if !FileManager.default.fileExists(atPath: folderUrl.absoluteString) {
            try? FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        return folderUrl
    }
    
    static func catalogUrl() -> URL {
        let asUrl = appSupportUrl()
        return asUrl.appendingPathComponent("catalog.json")
    }
    
    static func fontsUrl(family: String) -> URL {
        let asUrl = appSupportUrl()
        let fontsUrl = asUrl.appendingPathComponent("fonts", isDirectory: true)
        return fontsUrl.appendingPathComponent(family, isDirectory: true)
    }
}
