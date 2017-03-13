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
    @IBOutlet weak var menuButton: NSButton!
    
    let menuViewController: MenuViewController! = MenuViewController(nibName: "MenuViewController", bundle:nil)
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
       
        menuButton.image = StyleKit.imageOfMenuIcon(imageSize: menuButton.bounds.size, opacity: 1)
        menuButton.alternateImage = StyleKit.imageOfMenuIcon(imageSize: menuButton.bounds.size, opacity: 0.5)

        // Add and setup the child view controllers
        
        addChildViewController(menuViewController)
        addChildViewController(logonViewController)
        addChildViewController(listingViewController)
        
        menuViewController.delegate = self
        
        // Set the default view
        
        currentViewController = listingViewController
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        currentViewController = menuViewController
    }
}

extension MainViewController: MenuViewDelegate {
    
    func goToFontList() {
        currentViewController = listingViewController
    }
    
    func goToAccount() {
        currentViewController = logonViewController
    }
}
