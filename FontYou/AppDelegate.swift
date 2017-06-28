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
        
        // Change window's corner radius
        
        detachableWindow.backgroundColor = NSColor.clear
        detachableWindow.isOpaque = false
        detachableWindow.contentView!.wantsLayer = true
        detachableWindow.contentView!.layer!.cornerRadius = 15
        detachableWindow.contentView!.layer!.backgroundColor = StyleKit.lightGrey.cgColor
    
        // Set up status bar icon
        
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuBarIconGrey")
            button.target = detachableWindow
        
            // Observe for logins and change menu bar icon appropriately
            
            Fontstore.sharedInstance.authDetails.observeOn(.main).observeNext { authDetails in
                if authDetails != nil {
                    button.image = NSImage(named: "MenuBarIcon")
                } else {
                    button.image = NSImage(named: "MenuBarIconGrey")
                }
            }.dispose(in: reactive.bag)
        }
        
        // Set up desktop notifications
        
        NSUserNotificationCenter.default.delegate = self
        
        Fontstore.sharedInstance.notification.observeOn(.main).observeNext { notification in
            
            let delegate = NSApp.delegate as! AppDelegate
            
            if let notification = notification {
                switch notification {
                case .fontAdded(let family, let style):
                    delegate.showNotification(title: "New font available", text: "\(family) \(style)")
                case .fontInstalled(let family, let style):
                    delegate.showNotification(title: "Font installed", text: "\(family) \(style)")
                case .fontUninstalled(let family, let style):
                    delegate.showNotification(title: "Font uninstalled", text: "\(family) \(style)")
                }
            }

        }.dispose(in: reactive.bag)
        
        // Try to log in automatically
        
        Fontstore.sharedInstance.logonUsingStoredDetails()
    }
    
    func showNotification(title: String, text: String) -> Void {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = text
        
        NSUserNotificationCenter.default.deliver(notification)
    }

    func togglePopover(_ sender: AnyObject?) {
        detachableWindow.togglePopover(sender)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        Fontstore.sharedInstance.catalog.value?.saveCatalog()
        Fontstore.sharedInstance.activateInstalledFonts(activate: false)
        Fontstore.sharedInstance.sendDisconnectMessage(reason: "User has quit application.")
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
}
