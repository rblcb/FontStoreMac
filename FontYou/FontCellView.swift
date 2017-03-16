//
//  FontCellView.swift
//  FontYou
//
//  Created by Timothy Armes on 13/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class FontCellView: NSTableCellView {
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var installButton: RoundedButton!

    override func awakeFromNib() {
        nameLabel?.textColor = StyleKit.textBlack
        installButton.rectangleColor = StyleKit.textGrey
        
        installButton.font = NSFont(name: "Litmus-Regular", size: 12)
    }
}
