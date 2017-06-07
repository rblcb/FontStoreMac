//
//  LogonViewController.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond

class LogonViewController: NSViewController {

    @IBOutlet weak var seperatorView: NSView!
    @IBOutlet weak var loginLabel: NSTextField!
    @IBOutlet weak var rememberMeLabel: NSTextField!
    @IBOutlet weak var memberLabel: NSTextField!
    
    @IBOutlet weak var emailField: NSTextField!
    @IBOutlet weak var passwordField: NSTextField!
    @IBOutlet weak var rememberMeButton: NSButton!
    
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var forgottenButton: HoverButton!
    @IBOutlet weak var signupButton: HoverButton!
    
    let emailAddress = Observable<String>("")
    let password = Observable<String>("")
    let rememberMe = Observable<Int>(NSOffState)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set colors
        
        view.backgroundColor = NSColor.white
        seperatorView.backgroundColor = StyleKit.textBlack
        loginButton.textColor = NSColor.white
        
        // Set fonts
        
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
        
        // Set text
        
        forgottenButton.attributedTitle = NSAttributedString(string: "I've forgotten my password", attributes: attributes)
        
        // Set up hover cursors
        
        forgottenButton.cursor = NSCursor.pointingHand()
        signupButton.cursor = NSCursor.pointingHand()
        
        // Set up bindings
        
        bindViewModel()
    }
    
    func bindViewModel() {
        emailAddress.bidirectionalBind(to: emailField.reactive.editingString)
        password.bidirectionalBind(to: passwordField.reactive.editingString)
        rememberMe.bidirectionalBind(to: rememberMeButton.reactive.state)
        
        // Change colour and enabled state of the login button when the user has typed into both fields
        
        let logonAllowedSignal = combineLatest(emailField.reactive.editingString, passwordField.reactive.editingString) { email, pass in
            return email.characters.count > 0 && pass.characters.count > 0
        }
        
        logonAllowedSignal.bind(to: loginButton.reactive.isEnabled)
        logonAllowedSignal.map { $0 ? StyleKit.textBlack : StyleKit.lightGrey }.bind(to: loginButton.reactive.rectangleColor)
    }
    
    @IBAction func doLogin(_ sender: Any) {
        Fontstore.sharedInstance.login(email: emailAddress.value, password: password.value, rememberMe: rememberMe.value == NSOnState)
    }
    
    @IBAction func forgottonPassword(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "http://www.fontstore.com/reset-password")!)
    }
    
    @IBAction func signUp(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "http://www.fontstore.com/sign-up")!)
    }
}
