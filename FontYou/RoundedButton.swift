//
//  RoundedButton.swift
//  FontYou
//
//  Created by Timothy Armes on 14/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa
import Bond
import ReactiveKit

class RoundedButtonCell: NSButtonCell {

    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        if let roundedButton = controlView as? RoundedButton {
            let color = roundedButton.isHighlighted ? roundedButton.highlightColor : roundedButton.rectangleColor
            color.set()
            NSBezierPath(roundedRect: frame, xRadius: frame.height / 2, yRadius: frame.height / 2).fill()
        }
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Get the actual bounding box of the glyphs using CoreText
        
        let line = CTLineCreateWithAttributedString(attributedTitle)
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        let bb = CTRunGetImageBounds(runs[0], nil, CFRangeMake(0, 0))
        
        let height = bb.size.height - bb.origin.y
        
        // Adjust the frame to center the text vertically
        
        var newRect = cellFrame
        newRect.origin.y = newRect.size.height + bb.origin.y - (cellFrame.height - height) / 2
        
        attributedTitle.draw(with: newRect, options: [])
    }
}

@IBDesignable
class RoundedButton: NSButton {
    
    var rectangleColor = NSColor.black
    var highlightColor = StyleKit.primary
    
    @IBInspectable var textColor: NSColor? {
        didSet { setUpTitle() }
    }
    
    override var font: NSFont? {
        didSet { setUpTitle() }
    }
    
    func setUpTitle() {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        var attributes = [
            NSForegroundColorAttributeName: textColor ?? StyleKit.textBlack,
            NSParagraphStyleAttributeName: style
            ] as [String : Any]
        
        if let font = font {
            attributes[NSFontAttributeName] = font
        }
        
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        self.attributedTitle = attributedTitle
    }
}

extension ReactiveExtensions where Base: RoundedButton {
    var rectangleColor: Bond<NSColor> {
        return bond { button, color in
            button.rectangleColor = color
        }
    }
}
