//
//  ListingViewController.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class ListingViewController: NSViewController {

    @IBOutlet weak var outlineView: OutlineView!
    
    @IBOutlet weak var indicatorView: IndicatorStackView!
    @IBOutlet weak var installedButton: NSButton!
    @IBOutlet weak var newButton: NSButton!
    @IBOutlet weak var allButton: NSButton!
    @IBOutlet weak var searchButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton.image = StyleKit.imageOfSearchIcon(selected: false)
        searchButton.alternateImage = StyleKit.imageOfSearchIcon(selected: true)
        
        outlineView.action = #selector(onItemClicked)
    }
    
    @objc private func onItemClicked() {
        
        // Allow the user to expand/collapse an item by just clicking on the row
        
        let row = outlineView.clickedRow
        if let item = outlineView.item(atRow: row) as? String {
            if outlineView.isItemExpanded(item) {
                outlineView.animator().collapseItem(item)
            }
            else {
                outlineView.animator().expandItem(item)
            }
        }
    }
    
    @IBAction func displayInstalled(_ sender: Any) {
        indicatorView.positionIndicatorView(view: installedButton, animated: true)
    }

    @IBAction func displayNew(_ sender: Any) {
        indicatorView.positionIndicatorView(view: newButton, animated: true)
    }

    @IBAction func displayAll(_ sender: Any) {
        indicatorView.positionIndicatorView(view: allButton, animated: true)
    }
    
    @IBAction func displaySearch(_ sender: Any) {
        indicatorView.positionIndicatorView(view: searchButton, animated: true)
    }

}

extension ListingViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let family = item as? String {
            return FontStore.families[family]!.count
        }
        
        return FontStore.families.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let family = item as? String {
            return FontStore.families[family]![index]
        }
        
        return FontStore.families.keys.sorted()[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let family = item as? String {
            return FontStore.families[family]!.count > 0
        }
        
        return false
    }
}

extension ListingViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let view = ListingRowView()
        view.isFamily = item is String        
        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let font = item as? FontStoreItem {
            let view = outlineView.make(withIdentifier: "Font", owner: self) as? FontCellView
            if let textField = view?.nameLabel {
                textField.stringValue = font.name
                textField.font = NSFont.init(descriptor: font.fontDescriptor, size: 16)
            }
            
            return view
        }
        else if let family = item as? String {
            let view = outlineView.make(withIdentifier: "Family", owner: self) as? FamilyCellView
            if let textField = view?.nameLabel {
                textField.stringValue = family
                textField.font =  NSFont.init(descriptor: FontStore.sharedInstance.primaryFont(forFamily: family)!.fontDescriptor, size: 20)
            }
            
            if let textField = view?.numFontsLabel {
                let numFonts = FontStore.families[family]!.count
                textField.stringValue = numFonts > 1 ? "\(numFonts) Fonts" : "1 Font"
            }
            
            return view
        }
        
        return nil
    }

}
