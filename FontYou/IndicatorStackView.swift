//
//  IndicatorStackView.swift
//  FontYou
//
//  Created by Timothy Armes on 15/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

let indicatorWidth: CGFloat = 14
let indicatorHeight: CGFloat = 8
let indicatorOverlap: CGFloat = 3


class IndicatorStackView: NSStackView {
    
    let indicatorView = NSImageView(image: StyleKit.imageOfStackViewIndicator)
    var indicatorConstraints: [NSLayoutConstraint] = []
    weak var highlightedView: NSView? = nil
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        indicatorView.imageScaling = .scaleProportionallyUpOrDown
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a series of constraints that center the indicator over each of the subviews. This will allow us to 
        // animate the indicator position by changing the priorties. (Ideally we'd have one constraint and we'd change
        // the secondItem, but we're not allowed to do that)
        
        for view in views {
            let constraint = NSLayoutConstraint(item: indicatorView,
                                                attribute: .centerX,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .centerX,
                                                multiplier: 1,
                                                constant: 0)
            
            constraint.priority = NSLayoutPriorityDefaultLow
            indicatorConstraints.append(constraint)
        }
        
        // Start off over the first view
        
        indicatorConstraints[0].priority = NSLayoutPriorityDefaultHigh

        // Add the view and constraints
        
        self.addSubview(indicatorView)
        self.addConstraints(indicatorConstraints)
        
        // Add y-position and width/height constraints too
        
        self.addConstraints([
            NSLayoutConstraint(item: indicatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: indicatorWidth),
            NSLayoutConstraint(item: indicatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: indicatorHeight),
            NSLayoutConstraint(item: indicatorView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: -indicatorOverlap),
        ])
    }

    func positionIndicatorView(view: NSView, animated: Bool) {
        
        // Change the constraints so that the indicator is over the selected view
        
        NSAnimationContext.runAnimationGroup({ context in
            context.allowsImplicitAnimation = animated
            context.duration = 0.2
            for constaint in indicatorConstraints {
                constaint.priority = constaint.secondItem as? NSView == view ? NSLayoutPriorityDefaultHigh : NSLayoutPriorityDefaultLow
            }
            self.layoutSubtreeIfNeeded()
        }, completionHandler: nil)
    }
}
