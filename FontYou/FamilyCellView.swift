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
    @IBOutlet weak var installButton: RoundedButton!
    
    override func awakeFromNib() {
        nameLabel?.textColor = StyleKit.textBlack
        numFontsLabel.textColor = StyleKit.textGrey
        installButton.rectangleColor = StyleKit.textGrey
        
        numFontsLabel.font = NSFont(name: "Litmus-Regular", size: 11)
        installButton.font = NSFont(name: "Litmus-Regular", size: 12)
    }
}
