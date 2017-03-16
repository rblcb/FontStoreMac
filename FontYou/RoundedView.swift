//
//  RoundedView.swift
//  FontYou
//
//  Created by Timothy Armes on 16/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class RoundedView: NSView {

    var rectangleColor: NSColor = NSColor.white
    
    override func draw(_ dirtyRect: NSRect) {
        rectangleColor.set()
        NSBezierPath(roundedRect: bounds, xRadius: bounds.height / 2, yRadius: bounds.height / 2).fill()
    }
    
}
