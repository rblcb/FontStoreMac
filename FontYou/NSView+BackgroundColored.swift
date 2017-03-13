//
//  ColouredView.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

extension NSView {
    var backgroundColor: NSColor? {
        set {
            if self.layer == nil {
                self.wantsLayer = true
            }
            self.layer?.masksToBounds = true
            self.layer?.backgroundColor = newValue?.cgColor;
        }
        get {
            guard let cgColor = self.layer?.backgroundColor else { return nil }
            return NSColor(cgColor: cgColor)
        }
    }
}
