//
//  RoundedButton.swift
//  FontYou
//
//  Created by Timothy Armes on 14/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class RoundedButtonCell: NSButtonCell {

  override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
    StyleKit.drawRoundedRectangle(frame: frame, resizing: .stretch)
  }
}

@IBDesignable
class RoundedButton: NSButton {
    
    @IBInspectable var textColor: NSColor? {
        didSet {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            
            let attributes = [
                NSForegroundColorAttributeName: textColor ?? StyleKit.textBlack,
                NSParagraphStyleAttributeName: style
                ] as [String : Any]
            
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            self.attributedTitle = attributedTitle
        }
    }
}
