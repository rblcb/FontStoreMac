//
//  AnimatedImageVies.swift
//  FontYou
//
//  Created by Timothy Armes on 07/04/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

let key = "spinnerAnimation"

class AnimatedImageView: NSView {

    var images: [NSImage] = []

    override func awakeFromNib() {
        for i in 0...36 {
            let num = String(format: "%05d", i)
            images.append(NSImage(named: "loader_\(num)")!)
        }
        
        self.layer = CALayer()
        self.wantsLayer = true
    }
    
    func startAnimation() {
        guard self.layer?.animationKeys() == nil else { return }
        let anim = CAKeyframeAnimation(keyPath: "contents")
        anim.calculationMode = kCAAnimationDiscrete
        anim.duration = 1
        anim.repeatCount = Float.infinity
        anim.isRemovedOnCompletion = false
        anim.values = images
        self.layer!.add(anim, forKey: key)
    }
    
    func stopAnimation() {
       self.layer!.removeAllAnimations()
    }
}
