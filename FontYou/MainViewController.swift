//
//  MainViewController.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet weak var headerView: NSView!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var spinnerView: NSView!
    @IBOutlet weak var spinnerImageView: AnimatedImageView!
    @IBOutlet weak var usernameLabel: NSTextField!
    @IBOutlet weak var contextMenuButton: NSButton!
    @IBOutlet weak var menuButton: NSButton!
    
    @IBOutlet weak var spinnerLabel: NSTextField!
    @IBOutlet var contextMenu: NSMenu!
    
    @IBOutlet weak var accountMenuItem: NSMenuItem!
    @IBOutlet weak var settingsMenuItem: NSMenuItem!
    @IBOutlet weak var logoutMenuItem: NSMenuItem!
    
    let logonViewController: LogonViewController! = LogonViewController(nibName: "LogonViewController", bundle:nil)
    let listingViewController: ListingViewController! = ListingViewController(nibName: "ListingViewController", bundle:nil)
   
    var currentViewController: NSViewController! = nil {
        didSet {
            // The xib must be set up with appropriate autoresizing contraints and translatesAutoresizingMaskIntoConstraints = true.
            // We just need to adjust the framesize before we switch view controllers
            
            currentViewController.view.frame = contentView.bounds
            
            // Swap the view over
            
            if oldValue != nil {
                transition(from: oldValue!, to: currentViewController, options: .crossfade, completionHandler: nil)
            } else {
                contentView.addSubview(currentViewController.view)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set fonts
        
        headerView.backgroundColor = StyleKit.primary
        usernameLabel.font = NSFont(name: "Litmus-Regular", size: 12)
       
        // Set up spinner view
        
        spinnerView.backgroundColor = NSColor(calibratedWhite: 1, alpha: 0.8)
        
        // Add and setup the child view controllers
        
        addChildViewController(logonViewController)
        addChildViewController(listingViewController)
        
        // Set the default view
        
        currentViewController = logonViewController
        
        // Observe for logins
        
        Fontstore.sharedInstance.authDetails.observeOn(.main).observeNext { [weak self] authDetails in
            if let authDetails = authDetails {
                self?.usernameLabel.stringValue = "\(authDetails.firstName) \(authDetails.lastName)"
                self?.usernameLabel.textColor = NSColor.white
                self?.contextMenuButton.image = NSImage(named: "MenuIconBlack")
                self?.setUpMenu(loggedOn: true)
            } else {
                self?.usernameLabel.stringValue = "Welcome"
                self?.usernameLabel.textColor = StyleKit.textBlack
                self?.contextMenuButton.image = NSImage(named: "MenuIconWhite")
                
                self?.currentViewController = self?.logonViewController
                
                self?.logonViewController.emailAddress.value = ""
                self?.logonViewController.password.value = ""
                self?.logonViewController.rememberMe.value = NSOffState
                
                self?.setUpMenu(loggedOn: false)
            }
        }.dispose(in: reactive.bag)
        
        // Observe for catalog changes
        
        Fontstore.sharedInstance.catalog.observeOn(.main).observeNext { [weak self] catalog in
            if catalog != nil {
                self?.currentViewController = self?.listingViewController
            }
        }.dispose(in: reactive.bag)
        
        // Observe for catalog status changes
        
        Fontstore.sharedInstance.status.observeOn(.main).observeNext { [weak self] status in
            if let status = status {
                self?.spinnerLabel.stringValue = status
                self?.spinnerView.animator().isHidden = false
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
                    // Just starting this immediately doesn't always work (no idea why). A little delay fixes it.
                    self?.spinnerImageView.startAnimation()
                }
            }
            else {
                self?.spinnerView.animator().isHidden = true
                self?.spinnerImageView.stopAnimation()
            }
        }.dispose(in: reactive.bag)
        
        // Try to log in from stored details

        Fontstore.sharedInstance.logonUsingStoredDetails()
    }
    
    func setUpMenu(loggedOn: Bool) {
        accountMenuItem.isHidden = !loggedOn
        settingsMenuItem.isHidden = !loggedOn
        logoutMenuItem.isHidden = !loggedOn
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        if let event = NSApplication.shared().currentEvent {
            NSMenu.popUpContextMenu(contextMenu!, with: event, for: sender as! NSView)
        }
    }
    
    @IBAction func goToAccount(_ sender: Any) {
        if let url = Fontstore.sharedInstance.authDetails.value?.accountUrl {
            NSWorkspace.shared().open(url)
        }
    }
    
    @IBAction func visitFontstore(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "http://www.fontstore.com")!)
    }
    
    @IBAction func openHelp(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "http://www.fontstore.com/help")!)
    }
    
    @IBAction func openAbout(_ sender: Any) {
        NSApp.orderFrontStandardAboutPanel(options: [
            "ApplicationName": "Fontstore Installer",
            "Copyright":"Copyright © 2017 - Fontstore Pte Ltd"
        ])
    }
    
    @IBAction func logout(_ sender: Any) {
        Fontstore.sharedInstance.logout()
    }
    
    @IBAction func quit(_ sender: Any) {
        NSApp.terminate(sender)
    }
}
