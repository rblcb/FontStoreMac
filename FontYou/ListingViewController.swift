//
//  ListingViewController.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

enum DisplayedInfo {
    case installed
    case new
    case all
    case search
}

class ListingViewController: NSViewController {

    @IBOutlet weak var outlineView: OutlineView!
    
    @IBOutlet weak var indicatorView: IndicatorStackView!
    @IBOutlet weak var installedButton: TabButton!
    @IBOutlet weak var newButton: TabButton!
    @IBOutlet weak var allButton: TabButton!
    @IBOutlet weak var searchButton: NSButton!
    
    @IBOutlet weak var searchView: NSView!
    @IBOutlet weak var resultsLabel: NSTextField!
    @IBOutlet weak var searchField: NSSearchField!
    
    private let appFont = NSFont(name: "Litmus-Regular", size: 12)
    private var searchViewConstraint: NSLayoutConstraint? = nil
    fileprivate var fontFamilies: [String] = []
    fileprivate var filteredfontFamilies: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up text
        
        installedButton.baseTitle = "Installed"
        newButton.baseTitle = "New"
        allButton.baseTitle = "All Fonts"
        
        // Set control fonts
        
        let controls12: [NSControl] = [installedButton, newButton, allButton, resultsLabel, searchField]
        for control in controls12 {
            control.font = appFont
        }
        
        // Set up colors, actions etc.
        
        outlineView.action = #selector(onItemClicked)
        
        // We remove the search field's default border by inserting a white layer to hide it.
        // We can't just set the border to `none` due to a Cocoa bug:
        // http://stackoverflow.com/questions/38921355/osx-cocoa-nssearchfield-clear-button-not-responding-to-click
        //
        // The layer solution was chosen over the subclass solution because it's unlikely to have a negative effect
        // if the bug is corrected in a later version of MacOS.
        
        let maskLayer = CALayer()
        maskLayer.backgroundColor = NSColor.white.cgColor
        searchField.layer = maskLayer
        
        setButtonStates()
        
        // Prepare search and create a constraint to show/hide the search view. We start at zero height
        
        searchViewConstraint = NSLayoutConstraint(item: searchView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        searchViewConstraint?.priority = 900
        view.addConstraint(searchViewConstraint!)
        resultsLabel.stringValue = ""
        searchField.action = #selector(doSearch)
        
        // Watch for for store changes
        
        NotificationCenter.default.addObserver(forName: Notification.Name.init("FontStoreUpdated"), object: nil, queue: nil) { [weak self] _ in
            self?.fontFamilies = FontStore.sharedInstance.catalog.families.keys.sorted()
            self?.updateFontList()
        }
        
        // Prepare initial listing
        fontFamilies = FontStore.sharedInstance.catalog.families.keys.sorted()
        filteredfontFamilies = fontFamilies
        updateFontList()
    }
    
    var displayed: DisplayedInfo = .installed {
        didSet {
            switch displayed {
            case .installed:
                indicatorView.positionIndicatorView(view: installedButton, animated: true)
            case .new:
                indicatorView.positionIndicatorView(view: newButton, animated: true)
            case .all:
                indicatorView.positionIndicatorView(view: allButton, animated: true)
            case .search:
                indicatorView.positionIndicatorView(view: searchButton, animated: true)
            }

            setButtonStates()
            
            // Animate the opening/closing of the search view
            
            if oldValue == .search || displayed == .search {
                updateFontList()
                NSAnimationContext.runAnimationGroup({ context in
                    context.allowsImplicitAnimation = true
                    context.duration = 0.2
                    searchViewConstraint!.priority = displayed == .search ? NSLayoutPriorityDefaultLow : 900
                    view.layoutSubtreeIfNeeded()
                }, completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func displayInstalled(_ sender: Any) {
        displayed = .installed
    }

    @IBAction func displayNew(_ sender: Any) {
        displayed = .new
    }

    @IBAction func displayAll(_ sender: Any) {
        displayed = .all
    }
    
    @IBAction func displaySearch(_ sender: Any) {
        displayed = .search
    }

    func setButtonStates() {
        installedButton.state = displayed == .installed ? NSOnState : NSOffState
        newButton.state = displayed == .new ? NSOnState : NSOffState
        allButton.state = displayed == .all ? NSOnState : NSOffState
        searchButton.state = displayed == .search ? NSOnState : NSOffState
    }
    
    @objc func onItemClicked() {
        
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
    
    func updateFontList() {
        if displayed == .search && searchField.stringValue.characters.count > 0 {
            filteredfontFamilies = fontFamilies.filter { $0.localizedCaseInsensitiveContains(searchField.stringValue) }
        } else {
            filteredfontFamilies = fontFamilies
        }
        
        outlineView.reloadData()
    }
    
    func doSearch() {
        
        // Update the font list
        
        updateFontList()
        
        // Update the results label
        
        if (searchField.stringValue.characters.count == 0) {
            resultsLabel.stringValue = ""
        } else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let countAttributes = [ NSForegroundColorAttributeName: StyleKit.primary,
                                    NSParagraphStyleAttributeName: paragraphStyle ]
            let textAttributes = [ NSForegroundColorAttributeName: StyleKit.textGrey ]
            
            let countText = "\(filteredfontFamilies.count) "
            let text = filteredfontFamilies.count == 1 ? "result" : "results"
            let str = NSMutableAttributedString.init(string: countText + text, attributes: nil)
            
            str.setAttributes(countAttributes, range: NSRange(location: 0, length: countText.characters.count))
            str.setAttributes(textAttributes, range: NSRange(location: countText.characters.count, length: text.characters.count))
            resultsLabel.attributedStringValue = str
        }
    }
}

extension ListingViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let family = item as? String {
            return FontStore.sharedInstance.catalog.families[family]!.count
        }
        
        return filteredfontFamilies.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let family = item as? String {
            return FontStore.sharedInstance.catalog.families[family]![index]
        }
        
        return filteredfontFamilies[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let family = item as? String {
            return FontStore.sharedInstance.catalog.families[family]!.count > 0
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
        if let font = item as? CatalogItem {
            let view = outlineView.make(withIdentifier: "Font", owner: self) as? FontCellView
            if let textField = view?.nameLabel {
                textField.stringValue = font.name
                textField.font = NSFont.init(descriptor: font.fontDescriptor!, size: 16)
            }
            
            return view
        }
        else if let family = item as? String {
            let view = outlineView.make(withIdentifier: "Family", owner: self) as? FamilyCellView
            if let textField = view?.nameLabel {
                textField.stringValue = family
                textField.font =  NSFont.init(descriptor: FontStore.sharedInstance.catalog.primaryFont(forFamily: family)!.fontDescriptor!, size: 20)
            }
            
            if let textField = view?.numFontsLabel {
                let numFonts = FontStore.sharedInstance.catalog.families[family]!.count
                textField.stringValue = numFonts > 1 ? "\(numFonts) Fonts" : "1 Font"
            }
            
            return view
        }
        
        return nil
    }
}
