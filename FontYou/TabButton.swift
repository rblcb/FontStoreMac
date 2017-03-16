//
//  TabButton.swift
//  FontYou
//
//  Created by Timothy Armes on 16/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class TabButton: NSButton {

    var baseTitle: String = "" {
        didSet { setupText() }
    }
    
    var count = 0 {
        didSet { setupText() }
    }
    
    override var state: Int {
        didSet { setupText() }
        
    }
    
    func setupText() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let titleAttributes = [ NSForegroundColorAttributeName: state == NSOnState ? StyleKit.primary : StyleKit.textBlack,
                                NSParagraphStyleAttributeName: paragraphStyle ]
        let countAttributes = [ NSForegroundColorAttributeName: StyleKit.textGrey ]
        
        let countText = " (\(count))"
        let text = baseTitle + countText
        let str = NSMutableAttributedString.init(string: text, attributes: nil)
        
        str.setAttributes(titleAttributes, range: NSRange(location: 0, length: baseTitle.characters.count))
        str.setAttributes(countAttributes, range: NSRange(location: baseTitle.characters.count, length: countText.characters.count))
        self.attributedTitle = str
    }
}
