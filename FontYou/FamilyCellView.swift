//
//  FamilyCellView.swift
//  FontYou
//
//  Created by Timothy Armes on 13/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class FamilyCellView: NSTableCellView {
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var numFontsLabel: NSTextField!
    @IBOutlet weak var installButton: NSButton!
    
    override func awakeFromNib() {
        self.nameLabel?.textColor = StyleKit.textBlack
        self.numFontsLabel.textColor = StyleKit.textGrey
    }
}
