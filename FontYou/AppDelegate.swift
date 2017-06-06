//
//  AppDelegate.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    var detachableWindow: DetachableWindow!
    let fontStore = Fontstore.sharedInstance
    
    let mainViewController = MainViewController(nibName: "MainViewController", bundle: nil)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        PFMoveToApplicationsFolderIfNecessary()
        
        // For debug
        UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
        
        // Prepare the main window
        detachableWindow = DetachableWindow(statusItem: statusItem,
                                          styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                                          backing: .buffered,
                                          defer: true)

        detachableWindow.contentViewController = mainViewController
        detachableWindow.minSize = NSSize(width: 200, height: 400)
        detachableWindow.maxSize = NSSize(width: 600, height: 1500)
        
        // Set up status bar icon
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuBarIcon")
            button.target = detachableWindow
        }
    }

    func togglePopover(_ sender: AnyObject?) {
        detachableWindow.togglePopover(sender)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
