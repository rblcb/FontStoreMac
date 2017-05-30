//
//  NonClickableView.swift
//  FontStore
//
//  Created by Timothy Armes on 30/05/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class NonClickableView: NSView {

    override func mouseDown(with event: NSEvent) {
        // Do nothing. This stop the click proporgating to the views underneath
        return
    }
}
