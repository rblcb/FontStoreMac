//
//  OutlineView.swift
//  FontYou
//
//  Created by Timothy Armes on 13/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class OutlineView: NSOutlineView {

    // Use our own image for the disclosure triangle (it's the only way to control the colour)
    
    override func make(withIdentifier identifier: String, owner: Any?) -> NSView? {
        let view = super.make(withIdentifier: identifier, owner: owner)
        if identifier == NSOutlineViewDisclosureButtonKey {
            if let view = view as? NSButton {
                view.image = StyleKit.imageOfDisclosureTriangleClosed
                view.alternateImage = StyleKit.imageOfDisclosureTriangleOpen
            }
        }
        
        return view
    }
}
