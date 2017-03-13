//
//  EventMonitor.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

public class EventMonitor {
    
    private var monitor: Any?
    private let local: Bool
    private let mask: NSEventMask
    private let handler: (NSEvent) -> Void
    private var started = false
    
    public init(local: Bool, mask: NSEventMask, handler: @escaping (NSEvent) -> Void) {
        self.local = local
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        if monitor == nil {
            if local {
                monitor = NSEvent.addLocalMonitorForEvents(matching: mask) { event in
                    self.handler(event)
                    return event
                }
            } else {
                monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
            }
        }
    }
    
    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
