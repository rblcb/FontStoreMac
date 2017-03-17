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

        headerView.backgroundColor = StyleKit.primary
        fontStoreLabel.font = NSFont(name: "Litmus-Bold", size: 18)
        usernameLabel.font = NSFont(name: "Litmus-Regular", size: 12)
       
        // Add and setup the child view controllers
        
        addChildViewController(logonViewController)
        addChildViewController(listingViewController)
        
        // Set the default view
        
        currentViewController = logonViewController
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        if let event = NSApplication.shared().currentEvent {
            NSMenu.popUpContextMenu(contextMenu!, with: event, for: sender as! NSView)
        }
    }
    
    @IBAction func goToAccount(_ sender: Any) {
        currentViewController = logonViewController
    }
    
    @IBAction func quit(_ sender: Any) {
        NSApp.terminate(sender)
    }
}
