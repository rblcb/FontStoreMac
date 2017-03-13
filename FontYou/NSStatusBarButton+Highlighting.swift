//
//  NSStatusBarButton+highlighting.swift
//  FontYou
//
//  Created by Timothy Armes on 10/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

// As of OS X 10.10 most of NSStatusItem has been deprecated in favour of the button property.
// As a result, it's no longer possible to control the highlighting using any built in methods.
// This category will highlight the button when it's clicked, the code base is responsible for
// removing the highlight.

extension NSStatusBarButton {
    
    open override func mouseDown(with event: NSEvent) {
        
        if let target = self.target as? DetachableWindow {
            if (event.modifierFlags.contains(NSEventModifierFlags.control)) {
                self.rightMouseDown(with: event)
                return
            }
        
            self.highlight(true)
            target.togglePopover(self)
        } else {
            super.mouseDown(with: event)
        }
    }
}
