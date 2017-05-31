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
    var isNew: Bool
    var family: String
    var style: String
    var weight: Float?
    var slant: Float?
    var installed: Bool
    var downloadUrl: URL?
    var installedUrl: URL?
    var encryptedUrl: URL? {
        didSet {
            cachedDecryptedData = nil
        }
    }
    
    var fontDescriptor: NSFontDescriptor?
    private var cachedDecryptedData: Data?

    var decryptedData: Data? {
        get {
            if cachedDecryptedData != nil {
                return cachedDecryptedData
            }
            
            guard let encryptedUrl = encryptedUrl else { return nil }
            
            do {
                var data = try Data.init(contentsOf: encryptedUrl)
                data.xor(key: "lvcypbhupbdmg".data(using: .ascii)!)
                cachedDecryptedData = data
                return cachedDecryptedData
            } catch {
                print("Exception when loading contents of \(encryptedUrl)")
                return nil
            }
        }
    }
    
    init(uid: String, family: String, style: String) {
        self.uid = uid
        self.isNew = true
        self.family = family
        self.style = style
        self.installed = false
    }

    required init?(map: Map) {
        uid = ""
        family = ""
        style = ""
        isNew = false
        installed = false
    }

    func mapping(map: Map) {
        uid <- map["uid"]
        isNew <- map["isNew"]
        family <- map["family"]
        style <- map["style"]
        weight <- map["weight"]
        slant <- map["slant"]
        installed <- map["installed"]
        downloadUrl <- (map["downloadUrl"], URLTransform(shouldEncodeURLString: false))
        installedUrl <- (map["installedUrl"], transformURLIfExists)
        encryptedUrl <- (map["encryptedUrl"], transformURLIfExists)
    }
}

struct Catalog: Mappable {
    
    var userId: String
    var fonts = MutableObservableDictionary<String, CatalogItem>([:])
    var lastCatalogUpdate: Double?
    var lastUserUpdate: Double?
    
    let semaphore = DispatchSemaphore(value: 1)
    
    private var lock = NSLock()
    
    init?(map: Map) {
        self.userId = ""
    }
    
    init(userId: String) {
        self.userId = userId
    }
 
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        fonts <- map["fonts"]
        lastCatalogUpdate <- map["lastCatalogUpdate"]
        lastUserUpdate <- map["lastUserUpdate"]
    }
    
    @discardableResult
    mutating func addFont(uid: String,
                          familyName: String,
                          style: String,
                          weight: Float? = nil,
                          slant: Float? = nil,
                          downloadUrl: URL? = nil,
                          encryptedUrl: URL? = nil,
                          fontDescriptor: NSFontDescriptor? = nil) -> CatalogItem {
        
        // Try to find this item in the catalog
        
        var item: CatalogItem? = fonts[uid]
        
        if item != nil {
            // We have it, but we need to download it again
            
            item!.downloadUrl = downloadUrl
            item!.encryptedUrl = nil
        } else {
            // We don't have this item in the catalog - we need to add it
            item = CatalogItem(uid: uid, family: familyName, style: style)
            item!.weight = weight
            item!.slant = slant
            item!.downloadUrl = downloadUrl
            item!.encryptedUrl = encryptedUrl
            item!.fontDescriptor = fontDescriptor
        }
        
        // Update the catalog
        
        fonts[uid] = item!
        
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
        lock.lock(); defer { lock.unlock() }
        let fileUrl = Catalog.catalogUrl(userId: userId)
        try? self.toJSONString()?.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
    }
    
    static func loadCatalog(userId: String) -> Catalog? {
        let fileUrl = Catalog.catalogUrl(userId: userId)
        do {
            let json = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            if let catalog = Catalog(JSONString: json) {
                
                // Try to activate each font for use in the application
                // We decrypt each find and activate the font in-memory for this process.
                
                for (uid, item) in catalog.fonts {
                    guard item.encryptedUrl != nil else { continue }
                    let data = item.decryptedData
                    guard let font = FontUtility.createCGFont(from: data) else { print("Unable to create font from data for \(item.family).\(item.style)"); continue; }
                    guard FontUtility.activate(font) else { print("Unable to activate \(item.family).\(item.style)"); continue; }
                    if let desc = CTFontManagerCreateFontDescriptorFromData(data! as CFData) {
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

    static func installedUrl() -> URL {
        let asUrl = appSupportUrl()
        let folderUrl = asUrl.appendingPathComponent("installed", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folderUrl.absoluteString) {
            try? FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        return folderUrl
    }
}
