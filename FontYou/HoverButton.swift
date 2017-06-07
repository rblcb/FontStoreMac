//
//  HoverButton.swift
//  Fontstore
//
//  Created by Timothy Armes on 07/06/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class HoverButton: NSButton {

    var cursor:NSCursor? = nil
    
    override func resetCursorRects() {
        if let cursor = self.cursor {
            self.addCursorRect(self.bounds, cursor: cursor)
        } else {
            super.resetCursorRects()
        }
    }
}
