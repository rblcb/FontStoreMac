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
