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
    
    fileprivate var tree: [String:[CatalogItem]] = [:]
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
        
        bindViewModel()
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

    @IBAction func installedFamilyPressed(_ sender: Any) {
        let row = outlineView.row(for: sender as! NSView)
        let item = outlineView.item(atRow: row)
        
        if let familyName = item as? String,
            let family = tree[familyName] {
            let allInstalled = isFamilyInstalled(familyName: familyName)
            for item in family {
                FontStore.sharedInstance.installFont(uid: item.uid, installed: !allInstalled)
            }
        }
    }
    
    @IBAction func installFontPressed(_ sender: Any) {
        let row = outlineView.row(for: sender as! NSView)
        let item = outlineView.item(atRow: row)
        
        if let catalogItem = item as? CatalogItem {
            FontStore.sharedInstance.toggleInstall(uid: catalogItem.uid)
        }
    }
    
    func isFamilyInstalled(familyName: String) -> Bool {
        if let family = tree[familyName] {
            if family.contains(where: { $0.installed == false }) {
                return false
            }
            return true
        }
        
        return false
    }
    
    func bindViewModel() {
        
        // Watch for for store changes
        
        FontStore.sharedInstance.catalog.observeNext { catalog in
            if let catalog = catalog {
                
                func updateTreeIfNecessary(forIndexes indexes: [DictionaryIndex<String, CatalogItem>]) {
                    for index in indexes {
                        let (_, item) = catalog.fonts[index]
                        if item.installedUrl != nil {
                            self.updateTree()
                            return
                        }
                    }
                }
                
                func updateItemsIfNecessary(forIndexes indexes: [DictionaryIndex<String, CatalogItem>]) {
                    let rows = NSMutableIndexSet()
                    for index in indexes {
                        let (uid, item) = catalog.fonts[index]
                        if let siblings = self.tree[item.family],
                            let i = siblings.index(where: { $0.uid == uid }) {
                            self.tree[item.family]![i] = item
                            let row = self.outlineView.row(forItem: item)
                            if row != -1 {
                                rows.add(row)
                            }
                        }
                    }
                    
                    self.outlineView.reloadData(forRowIndexes: rows as IndexSet, columnIndexes: IndexSet(integer: 0))
                }
                
                catalog.fonts.observeNext { update in
                    switch update.kind {
                    case .reset:
                        self.updateTree()
                    case .inserts(let indexes):
                        updateTreeIfNecessary(forIndexes: indexes)
                    case .deletes(let indexes):
                        updateTreeIfNecessary(forIndexes: indexes)
                    case .updates(let indexes):
                        updateItemsIfNecessary(forIndexes: indexes)
                    default:
                        break
                    }
                    }.dispose(in: self.reactive.bag)
                }
            }.dispose(in: self.reactive.bag)
        
        // Prepare initial listing
        
        updateFontList()
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

    // Creates a tree of available fonts based on family name
    
    func updateTree() {
        if let fonts = FontStore.sharedInstance.catalog.value?.fonts {
        
            var tree: [String:[CatalogItem]] = [:]
            for (_, item) in fonts {
                if item.installedUrl != nil {
                    let family = item.family
                    var siblings = tree[family] ?? []
                    siblings.append(item)
                    tree[family] = siblings
                }
            }
            
            for (family, siblings) in tree {
                tree[family] = siblings.sorted { $0.weight! > $1.weight! }
            }
            
            self.tree = tree
            self.fontFamilies = tree.keys.sorted()
            updateFontList()
        }
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
}

extension ListingViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let family = item as? String {
            return tree[family]!.count
        }
        
        return filteredfontFamilies.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let family = item as? String {
            return tree[family]![index]
        }
        
        return filteredfontFamilies[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let family = item as? String {
            return tree[family]!.count > 0
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
                textField.stringValue = font.style
                textField.font = NSFont.init(descriptor: font.fontDescriptor!, size: 16)
            }
            
            view?.installButton.title = font.installed ? "Uninstall" : "Install"
            view?.installButton.rectangleColor = font.installed ? StyleKit.textGrey : StyleKit.primary
            view?.installButton.highlightColor = font.installed ? StyleKit.primary : StyleKit.textGrey
            view?.installButton.textColor = NSColor.white
            
            return view
        }
        else if let family = item as? String {
            let view = outlineView.make(withIdentifier: "Family", owner: self) as? FamilyCellView
            if let textField = view?.nameLabel {
                textField.stringValue = family
                textField.font =  NSFont.init(descriptor: primaryFont(forFamily: family)!.fontDescriptor!, size: 18)
            }
            
            if let textField = view?.numFontsLabel {
                let numFonts = tree[family]!.count
                textField.stringValue = numFonts > 1 ? "\(numFonts) Fonts" : "1 Font"
            }
            
            let installed = isFamilyInstalled(familyName: family)
            view?.installButton.title = installed ? "Uninstall" : "Install"
            view?.installButton.rectangleColor = installed ? StyleKit.textGrey : StyleKit.primary
            view?.installButton.highlightColor = installed ? StyleKit.primary : StyleKit.textGrey
            view?.installButton.textColor = NSColor.white
            
            return view
        }
        
        return nil
    }
}
