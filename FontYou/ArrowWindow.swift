//
//  ArrowWindow.swift
//  FontYou
//
//  Created by Timothy Armes on 23/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class ArrowLayer: CALayer {
    override func draw(in ctx: CGContext) {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrent(NSGraphicsContext(cgContext: ctx, flipped: true))
        StyleKit.drawPopupArrow(frame: CGRect(x: 0,
                                              y: Constants.Dimensions.arrowWindowOverlap,
                                              width: self.frame.width,
                                              height: self.frame.height - Constants.Dimensions.arrowWindowOverlap))
        NSGraphicsContext.restoreGraphicsState()
    }
}

class ArrowView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        wantsLayer = true
        
        let layer = ArrowLayer()
        layer.frame = frameRect;
        self.layer = layer
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class ArrowWindow: NSWindow {
    
    let arrowView: ArrowView!
    
    
    init() {
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: Constants.Dimensions.arrow)
        arrowView = ArrowView(frame: frame)
        
        super.init(contentRect: frame,
                  styleMask: [.borderless],
                  backing: .buffered,
                  defer: true)
        
        backgroundColor = NSColor.clear
        contentView?.addSubview(arrowView)
        
        arrowView.layer?.contentsScale = self.backingScaleFactor
        arrowView.needsDisplay = true
    }
    
    func hideArrow() {
        arrowView.animator().alphaValue = 0
    }
    
    func showArrow() {
        arrowView.animator().alphaValue = 1
    }
    
    override func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool {
        return true
    }
}
