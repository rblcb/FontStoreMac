//
//  ListingRowView.swift
//  FontYou
//
//  Created by Timothy Armes on 13/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class ListingRowView: NSTableRowView {
    
    var isFamily = false

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        var backgroundColor: NSColor
        var dividerColor: NSColor
        
        if isFamily {
            backgroundColor = NSColor.white
            dividerColor = StyleKit.lightGrey
        } else {
            backgroundColor = StyleKit.lightGrey
            dividerColor = NSColor.white
        }
        
        backgroundColor.set()
        NSRectFill(dirtyRect)
        
        dividerColor.set()
        let dividerRect = NSRect.init(x: 0, y: 0, width: self.frame.width, height: 1)
        NSRectFill(dividerRect)
    }
}
