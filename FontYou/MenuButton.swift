//
//  MenuButton.swift
//  FontYou
//
//  Created by Timothy Armes on 20/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class MenuButtonCell: NSButtonCell {
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        StyleKit.drawMenuIcon(frame: cellFrame)
    }
}
