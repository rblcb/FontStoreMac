//
//  VerticallyCenteredTextFieldCell.swift
//  Fontstore
//
//  Created by Timothy Armes on 08/06/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class VerticallyCenteredTextFieldCell: NSTextFieldCell {

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {

        // Get the actual bounding box of the glyphs using CoreText
        
        let line = CTLineCreateWithAttributedString(attributedStringValue)
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        let bb = CTRunGetImageBounds(runs[0], nil, CFRangeMake(0, 0))
        
        let height = bb.size.height - bb.origin.y
        
        // Adjust the frame to center the text vertically
        
        var newRect = cellFrame
        newRect.origin.y = newRect.size.height + bb.origin.y - (cellFrame.height - height) / 2

        attributedStringValue.draw(with: newRect, options: [])
    }
}
