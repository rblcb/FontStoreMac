//
//  LogonViewController.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class LogonViewController: NSViewController {

    @IBOutlet weak var seperatorView: NSView!
    @IBOutlet weak var loginLabel: NSTextField!
    @IBOutlet weak var rememberMeLabel: NSTextField!
    @IBOutlet weak var memberLabel: NSTextField!
    
    @IBOutlet weak var emailField: NSTextField!
    @IBOutlet weak var passwordField: NSTextField!
    
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var forgottenButton: NSButton!
    @IBOutlet weak var signupButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = NSColor.white
        seperatorView.backgroundColor = StyleKit.textBlack
        
        let litmus12 = NSFont(name: "Litmus-Bold", size: 12)
        let litmus14 = NSFont(name: "Litmus-Bold", size: 14)
        let litmus24 = NSFont(name: "Litmus-Bold", size: 24)
        
        let controls12: [NSControl] = [loginLabel, rememberMeLabel, memberLabel, signupButton]
        for control in controls12 {
            control.font = litmus12
        }
        
        loginButton.font = litmus14
        emailField.font = litmus24
        passwordField.font = litmus24
        
        let centerStyle = NSMutableParagraphStyle()
        centerStyle.alignment = .center
        
        let attributes = [
            NSForegroundColorAttributeName: StyleKit.textGrey,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
            NSFontAttributeName: litmus12!,
            NSParagraphStyleAttributeName: centerStyle
        ] as [String : Any]
        
        forgottenButton.attributedTitle = NSAttributedString(string: "I've forgotten my password", attributes: attributes)
    }
    
}
