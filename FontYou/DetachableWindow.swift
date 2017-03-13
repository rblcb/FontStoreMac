//
//  DetachableWindow
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class DetachableWindow: NSWindow {
    
    let arrowWindow = ArrowWindow()
    let statusItem: NSStatusItem!
    var outsideClickEventMonitor: EventMonitor!
    var endOfMoveEventMonitor: EventMonitor!
    var isDetached = false

    var controlsHidden: Bool {
        set {
            standardWindowButton(.closeButton)?.isHidden = newValue
            standardWindowButton(.miniaturizeButton)?.isHidden = newValue
            standardWindowButton(.zoomButton)?.isHidden = newValue
        }
        get {
            return standardWindowButton(.closeButton)?.isHidden ?? true
        }
    }
    
    init(statusItem: NSStatusItem, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        
        self.statusItem = statusItem
        
        super.init(contentRect: NSZeroRect, styleMask: style, backing: bufferingType, defer: flag)

        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.isReleasedWhenClosed = false
        self.delegate = self
        
        self.addChildWindow(arrowWindow, ordered: .above)

        createMonitors()
    }
    
    func createMonitors() {
        
        // Create an event monitor to close the popover when clicking elsewhere
        outsideClickEventMonitor = EventMonitor(local: false, mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
            if self.isVisible && self.isDetached == false {
                self.closeDetachableWindow(event)
            }
        }
        
        // Create an event monitor to detect when the window move/resize has finished
        endOfMoveEventMonitor = EventMonitor(local: true, mask: [.leftMouseUp]) { [weak self] event in
            if let s = self {
                s.attachWindowIfRequired()
                s.statusItem.button?.highlight(s.isInAttachZone())
            }
        }
    }
    
    func showDetachableWindow(_ sender: AnyObject?) {
        
        // Open window underneath the status icon
        
        let newFrame = attachedFrame()
        controlsHidden = true
        setFrame(newFrame, display: true)
        NSApp.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(self)
        isDetached = false
        statusItem.button?.highlight(true)
        
        // The ArrowWindow
        
        positionArrowWindow(mainWindowFrame: newFrame)
        arrowWindow.orderFront(self)
        
        // Start monitoring for clicks outside of the window
        
        outsideClickEventMonitor?.start()
    }

    func closeDetachableWindow(_ sender: AnyObject?) {
        performClose(sender)
    }
    
    func togglePopover(_ sender: AnyObject?) {
        
        // If the window is detached, just bring it to the front
        if isDetached && isVisible {
            NSApp.activate(ignoringOtherApps: true)
            makeKeyAndOrderFront(self)

            // Provide some flash feedback to the status bar item
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                self?.statusItem.button?.highlight(false)
            }

            return
        }
        
        // Otherwise, toggle the popup
        if isVisible {
            closeDetachableWindow(sender)
        } else {
            showDetachableWindow(sender)
        }
    }
    
    func positionArrowWindow(mainWindowFrame frame: CGRect) {
        
        // The ArrowWindow needs to be positioned at the top of the main window.
        
        let frame = frame
        let arrowFrame = CGRect(x: frame.midX - Constants.Dimensions.arrow.width / 2,
                                y:frame.maxY - Constants.Dimensions.arrowWindowOverlap,
                                width: Constants.Dimensions.arrow.width,
                                height: Constants.Dimensions.arrow.height)
        
        arrowWindow.setFrame(arrowFrame, display: true, animate: false)
    }
    
    func attachedFrame() -> NSRect {
        
        // Try to return a frame underneath the status item
        if let button = statusItem.button {
            let buttonFrame = button.window?.frame
            let windowSize = frame.size
            let newFrame = CGRect(x: buttonFrame!.midX - windowSize.width / 2,
                                  y:buttonFrame!.minY - windowSize.height - Constants.Dimensions.arrow.height + 1,
                                  width: windowSize.width,
                                  height: windowSize.height)
            return newFrame
        }
        
        return frame
    }

    func isInAttachZone() -> Bool {
        
        if let button = statusItem.button {
            let buttonPos = CGPoint(x: button.window!.frame.midX, y: button.window!.frame.minY)
            let windowPos = CGPoint(x: frame.midX, y: frame.maxY + Constants.Dimensions.arrow.height)
            let xDist = abs(buttonPos.x - windowPos.x)
            let yDist = abs(buttonPos.y - windowPos.y)
            return yDist <= Constants.Dimensions.arrow.height * 1.5 && xDist <= 80
        }
        
        return false
    }
    
    func attachWindowIfRequired() {
        
        // Stop listening for mouse up events
        endOfMoveEventMonitor?.stop()
        
        if isInAttachZone() {
            // We're in the attachment zone, smoothly move the window back to the exact attachment point
            positionArrowWindow(mainWindowFrame: frame)
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                context.duration = 0.2
                animator().setFrame(attachedFrame(), display: true)
            }, completionHandler: nil)
            
            arrowWindow.showArrow()
            controlsHidden = true
            isDetached = false
            
            // Outside clicks should now close the window...
            outsideClickEventMonitor?.start()

        } else {
            // We're detached
            isDetached = true
            outsideClickEventMonitor?.stop()
        }
    }
}

extension DetachableWindow: NSWindowDelegate {
    
    func windowDidMove(_ notification: Notification) {
        if isInAttachZone() {
            arrowWindow.showArrow()
            controlsHidden = true
        }
        else {
            arrowWindow.hideArrow()
            controlsHidden = false
        }
        
        if NSEvent.pressedMouseButtons() == 0 {
            // No buttons pressed - the resize is already over.
            attachWindowIfRequired()
            if isVisible {
                statusItem.button?.highlight(isInAttachZone())
            }

        } else {
            // Wait for the buttons to be released before we reposition
            endOfMoveEventMonitor!.start()
        }
    }

    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        
        // Just before we resize we have to remove the child window, otherwise it gets moved
        // incorrectly once we reposition the window in its attached position in windowDidResize
        
        removeChildWindow(arrowWindow)
        return frameSize
    }
    
    func windowDidResize(_ notification: Notification) {
        
        if !isDetached {
            // If we're attached, we keep the window centered under the status item
            setFrame(attachedFrame(), display: true)
        }
        
        // Reattach the arrow window
        if (childWindows?.count == 0) {
            positionArrowWindow(mainWindowFrame: frame)
            addChildWindow(arrowWindow, ordered: .above)
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        outsideClickEventMonitor?.stop()
        endOfMoveEventMonitor?.stop()
        statusItem.button?.highlight(false)
        isDetached = false
    }
}
