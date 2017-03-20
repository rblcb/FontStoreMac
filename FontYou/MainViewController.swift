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
    @IBOutlet weak var usernameLabel: NSTextField!
    @IBOutlet weak var menuButton: NSButton!
    @IBOutlet weak var fontStoreLabel: NSTextField!
    
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
        fontStoreLabel.font = NSFont(name: "Litmus-Bold", size: 18)
        usernameLabel.font = NSFont(name: "Litmus-Regular", size: 12)
       
        // Add and setup the child view controllers
        
        addChildViewController(logonViewController)
        addChildViewController(listingViewController)
        
        // Set the default view
        
        currentViewController = logonViewController
        
        // Observe for logins
        
        FontStore.sharedInstance.authDetails.observeNext { [weak self] authDetails in
            if let authDetails = authDetails {
                self?.usernameLabel.stringValue = "\(authDetails.firstName) \(authDetails.lastName)"
                self?.currentViewController = self?.listingViewController
                self?.setUpMenu(loggedOn: true)
            } else {
                self?.usernameLabel.stringValue = "Welcome"
                self?.currentViewController = self?.logonViewController
                self?.setUpMenu(loggedOn: false)
            }
        }.dispose(in: reactive.bag)
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
        if let url = FontStore.sharedInstance.authDetails.value?.accountUrl {
            NSWorkspace.shared().open(url)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        FontStore.sharedInstance.logout()
    }
    
    @IBAction func quit(_ sender: Any) {
        NSApp.terminate(sender)
    }
}
