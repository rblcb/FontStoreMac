//
//  StyleKit.swift
//  FontYou
//
//  Created by Timothy Armes on 15/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import Cocoa

public class StyleKit : NSObject {

    //// Cache

    private struct Cache {
        static let primary: NSColor = NSColor(red: 0, green: 0.471, blue: 1, alpha: 1)
        static let textGrey: NSColor = NSColor(red: 0.706, green: 0.706, blue: 0.706, alpha: 1)
        static let lightGrey: NSColor = NSColor(red: 0.957, green: 0.957, blue: 0.957, alpha: 1)
        static var imageOfDisclosureTriangleOpen: NSImage?
        static var imageOfDisclosureTriangleClosed: NSImage?
        static var imageOfStackViewIndicator: NSImage?
    }

    //// Colors

    public dynamic class var primary: NSColor { return Cache.primary }
    public dynamic class var textGrey: NSColor { return Cache.textGrey }
    public dynamic class var lightGrey: NSColor { return Cache.lightGrey }

    //// Drawing Methods

    public dynamic class func drawMenuIcon(frame: NSRect = NSRect(x: 0, y: 0, width: 22, height: 19), opacity: CGFloat = 1) {
        //// General Declarations
        let context = NSGraphicsContext.current()!.cgContext

        //// Color Declarations
        let white = NSColor(red: 1, green: 1, blue: 1, alpha: 1)

        //// Group
        NSGraphicsContext.saveGraphicsState()
        context.setAlpha(opacity)
        context.beginTransparencyLayer(auxiliaryInfo: nil)


        //// Rectangle Drawing
        let rectangleCornerRadius: CGFloat = 2.5
        let rectangleRect = NSRect(x: frame.minX, y: frame.minY, width: 22, height: 5)
        let rectangleInnerRect = rectangleRect.insetBy(dx: rectangleCornerRadius, dy: rectangleCornerRadius)
        let rectanglePath = NSBezierPath()
        rectanglePath.move(to: NSPoint(x: rectangleRect.minX, y: rectangleRect.minY))
        rectanglePath.appendArc(withCenter: NSPoint(x: rectangleInnerRect.maxX, y: rectangleInnerRect.minY), radius: rectangleCornerRadius, startAngle: 270, endAngle: 360)
        rectanglePath.appendArc(withCenter: NSPoint(x: rectangleInnerRect.maxX, y: rectangleInnerRect.maxY), radius: rectangleCornerRadius, startAngle: 0, endAngle: 90)
        rectanglePath.line(to: NSPoint(x: rectangleRect.minX, y: rectangleRect.maxY))
        rectanglePath.close()
        white.setFill()
        rectanglePath.fill()


        //// Rectangle 2 Drawing
        let rectangle2CornerRadius: CGFloat = 2.5
        let rectangle2Rect = NSRect(x: frame.minX, y: frame.minY + 7, width: 22, height: 5)
        let rectangle2InnerRect = rectangle2Rect.insetBy(dx: rectangle2CornerRadius, dy: rectangle2CornerRadius)
        let rectangle2Path = NSBezierPath()
        rectangle2Path.move(to: NSPoint(x: rectangle2Rect.minX, y: rectangle2Rect.minY))
        rectangle2Path.appendArc(withCenter: NSPoint(x: rectangle2InnerRect.maxX, y: rectangle2InnerRect.minY), radius: rectangle2CornerRadius, startAngle: 270, endAngle: 360)
        rectangle2Path.appendArc(withCenter: NSPoint(x: rectangle2InnerRect.maxX, y: rectangle2InnerRect.maxY), radius: rectangle2CornerRadius, startAngle: 0, endAngle: 90)
        rectangle2Path.line(to: NSPoint(x: rectangle2Rect.minX, y: rectangle2Rect.maxY))
        rectangle2Path.close()
        white.setFill()
        rectangle2Path.fill()


        //// Rectangle 3 Drawing
        let rectangle3Path = NSBezierPath(roundedRect: NSRect(x: frame.minX + 11, y: frame.minY + 14, width: 11, height: 5), xRadius: 2.5, yRadius: 2.5)
        white.setFill()
        rectangle3Path.fill()


        context.endTransparencyLayer()
        NSGraphicsContext.restoreGraphicsState()
    }

    public dynamic class func drawMenubar(frame: NSRect = NSRect(x: 0, y: 0, width: 32, height: 32)) {
        //// Color Declarations
        let black = NSColor(red: 0, green: 0, blue: 0, alpha: 1)

        //// Bezier 2 Drawing
        let bezier2Path = NSBezierPath()
        bezier2Path.move(to: NSPoint(x: frame.minX + 0.72749 * frame.width, y: frame.minY + 0.91811 * frame.height))
        bezier2Path.line(to: NSPoint(x: frame.minX + 0.75073 * frame.width, y: frame.minY + 0.89471 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.75073 * frame.width, y: frame.minY + 0.80109 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.77639 * frame.width, y: frame.minY + 0.86885 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.77639 * frame.width, y: frame.minY + 0.82694 * frame.height))
        bezier2Path.line(to: NSPoint(x: frame.minX + 0.51506 * frame.width, y: frame.minY + 0.56372 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.45014 * frame.width, y: frame.minY + 0.54698 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.49749 * frame.width, y: frame.minY + 0.54601 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.47243 * frame.width, y: frame.minY + 0.54043 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.42718 * frame.width, y: frame.minY + 0.55912 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.44194 * frame.width, y: frame.minY + 0.54938 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.43412 * frame.width, y: frame.minY + 0.55343 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.42212 * frame.width, y: frame.minY + 0.56372 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.42543 * frame.width, y: frame.minY + 0.56055 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.42374 * frame.width, y: frame.minY + 0.56208 * frame.height))
        bezier2Path.line(to: NSPoint(x: frame.minX + 0.35241 * frame.width, y: frame.minY + 0.63393 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.33044 * frame.width, y: frame.minY + 0.65606 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.35178 * frame.width, y: frame.minY + 0.63456 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.33044 * frame.width, y: frame.minY + 0.65606 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.29549 * frame.width, y: frame.minY + 0.69127 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.30984 * frame.width, y: frame.minY + 0.67681 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.29549 * frame.width, y: frame.minY + 0.69127 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.19342 * frame.width, y: frame.minY + 0.68153 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.26463 * frame.width, y: frame.minY + 0.71333 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.22143 * frame.width, y: frame.minY + 0.70974 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.18296 * frame.width, y: frame.minY + 0.57738 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.16532 * frame.width, y: frame.minY + 0.65323 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.16183 * frame.width, y: frame.minY + 0.60951 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.33810 * frame.width, y: frame.minY + 0.41929 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.18751 * frame.width, y: frame.minY + 0.57177 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.26277 * frame.width, y: frame.minY + 0.49543 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.48502 * frame.width, y: frame.minY + 0.27102 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.40029 * frame.width, y: frame.minY + 0.35642 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.46253 * frame.width, y: frame.minY + 0.29369 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.86457 * frame.width, y: frame.minY + 0.65332 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.63154 * frame.width, y: frame.minY + 0.41860 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.86457 * frame.width, y: frame.minY + 0.65332 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.95751 * frame.width, y: frame.minY + 0.65332 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.89024 * frame.width, y: frame.minY + 0.67917 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.93185 * frame.width, y: frame.minY + 0.67917 * frame.height))
        bezier2Path.line(to: NSPoint(x: frame.minX + 0.98075 * frame.width, y: frame.minY + 0.62992 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.98075 * frame.width, y: frame.minY + 0.53630 * frame.height), controlPoint1: NSPoint(x: frame.minX + 1.00642 * frame.width, y: frame.minY + 0.60406 * frame.height), controlPoint2: NSPoint(x: frame.minX + 1.00642 * frame.width, y: frame.minY + 0.56215 * frame.height))
        bezier2Path.line(to: NSPoint(x: frame.minX + 0.53149 * frame.width, y: frame.minY + 0.08378 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.43855 * frame.width, y: frame.minY + 0.08378 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.50583 * frame.width, y: frame.minY + 0.05793 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.46422 * frame.width, y: frame.minY + 0.05793 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.37853 * frame.width, y: frame.minY + 0.14423 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.43777 * frame.width, y: frame.minY + 0.08457 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.37853 * frame.width, y: frame.minY + 0.14423 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.36884 * frame.width, y: frame.minY + 0.15400 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.37764 * frame.width, y: frame.minY + 0.14514 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.37450 * frame.width, y: frame.minY + 0.14830 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.22896 * frame.width, y: frame.minY + 0.29489 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.34721 * frame.width, y: frame.minY + 0.17579 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.28881 * frame.width, y: frame.minY + 0.23461 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.11856 * frame.width, y: frame.minY + 0.40610 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.18940 * frame.width, y: frame.minY + 0.33475 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.14919 * frame.width, y: frame.minY + 0.37524 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.06546 * frame.width, y: frame.minY + 0.45957 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.08691 * frame.width, y: frame.minY + 0.43797 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.06546 * frame.width, y: frame.minY + 0.45957 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.07724 * frame.width, y: frame.minY + 0.79855 * frame.height), controlPoint1: NSPoint(x: frame.minX + -0.01885 * frame.width, y: frame.minY + 0.55709 * frame.height), controlPoint2: NSPoint(x: frame.minX + -0.01510 * frame.width, y: frame.minY + 0.70554 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.41378 * frame.width, y: frame.minY + 0.80987 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.16958 * frame.width, y: frame.minY + 0.89157 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.31697 * frame.width, y: frame.minY + 0.89534 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.46891 * frame.width, y: frame.minY + 0.75128 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.41586 * frame.width, y: frame.minY + 0.80614 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.44120 * frame.width, y: frame.minY + 0.77970 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.63455 * frame.width, y: frame.minY + 0.91811 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.54660 * frame.width, y: frame.minY + 0.82953 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.63455 * frame.width, y: frame.minY + 0.91811 * frame.height))
        bezier2Path.curve(to: NSPoint(x: frame.minX + 0.72749 * frame.width, y: frame.minY + 0.91811 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.66021 * frame.width, y: frame.minY + 0.94396 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.70182 * frame.width, y: frame.minY + 0.94396 * frame.height))
        bezier2Path.close()
        black.setFill()
        bezier2Path.fill()
    }

    public dynamic class func drawSearchIcon(frame targetFrame: NSRect = NSRect(x: 0, y: 0, width: 30, height: 30), resizing: ResizingBehavior = .aspectFit, selected: Bool = true) {
        //// General Declarations
        let context = NSGraphicsContext.current()!.cgContext
        
        //// Resize to Target Frame
        NSGraphicsContext.saveGraphicsState()
        let resizedFrame: NSRect = resizing.apply(rect: NSRect(x: 0, y: 0, width: 30, height: 30), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 30, y: resizedFrame.height / 30)


        //// Color Declarations
        let white = NSColor(red: 1, green: 1, blue: 1, alpha: 1)

        //// Variable Declarations
        let backgroundColour: NSColor = selected ? StyleKit.textGrey : StyleKit.lightGrey
        let foregroundColour: NSColor = selected ? white : StyleKit.textGrey

        //// Oval Drawing
        let ovalPath = NSBezierPath(ovalIn: NSRect(x: 5, y: 5, width: 21, height: 20))
        foregroundColour.setFill()
        ovalPath.fill()


        //// Bezier Drawing
        let bezierPath = NSBezierPath()
        bezierPath.move(to: NSPoint(x: 21.43, y: 14.91))
        bezierPath.curve(to: NSPoint(x: 14.91, y: 8.39), controlPoint1: NSPoint(x: 21.43, y: 11.31), controlPoint2: NSPoint(x: 18.51, y: 8.39))
        bezierPath.curve(to: NSPoint(x: 12.83, y: 8.73), controlPoint1: NSPoint(x: 14.18, y: 8.39), controlPoint2: NSPoint(x: 13.49, y: 8.51))
        bezierPath.curve(to: NSPoint(x: 8.76, y: 12.74), controlPoint1: NSPoint(x: 10.94, y: 9.37), controlPoint2: NSPoint(x: 9.43, y: 10.85))
        bezierPath.curve(to: NSPoint(x: 8.39, y: 14.91), controlPoint1: NSPoint(x: 8.52, y: 13.42), controlPoint2: NSPoint(x: 8.39, y: 14.15))
        bezierPath.curve(to: NSPoint(x: 14.91, y: 21.43), controlPoint1: NSPoint(x: 8.39, y: 18.51), controlPoint2: NSPoint(x: 11.31, y: 21.43))
        bezierPath.curve(to: NSPoint(x: 21.43, y: 14.91), controlPoint1: NSPoint(x: 18.51, y: 21.43), controlPoint2: NSPoint(x: 21.43, y: 18.51))
        bezierPath.close()
        bezierPath.move(to: NSPoint(x: 15, y: 22.68))
        bezierPath.curve(to: NSPoint(x: 7.32, y: 15), controlPoint1: NSPoint(x: 10.76, y: 22.68), controlPoint2: NSPoint(x: 7.32, y: 19.24))
        bezierPath.curve(to: NSPoint(x: 8.06, y: 11.71), controlPoint1: NSPoint(x: 7.32, y: 13.82), controlPoint2: NSPoint(x: 7.59, y: 12.71))
        bezierPath.curve(to: NSPoint(x: 12.18, y: 7.85), controlPoint1: NSPoint(x: 8.89, y: 9.96), controlPoint2: NSPoint(x: 10.37, y: 8.57))
        bezierPath.curve(to: NSPoint(x: 15, y: 7.32), controlPoint1: NSPoint(x: 13.06, y: 7.51), controlPoint2: NSPoint(x: 14.01, y: 7.32))
        bezierPath.curve(to: NSPoint(x: 19.81, y: 9.02), controlPoint1: NSPoint(x: 16.82, y: 7.32), controlPoint2: NSPoint(x: 18.5, y: 7.96))
        bezierPath.curve(to: NSPoint(x: 21.13, y: 7.7), controlPoint1: NSPoint(x: 20.35, y: 8.48), controlPoint2: NSPoint(x: 21.13, y: 7.7))
        bezierPath.curve(to: NSPoint(x: 21.89, y: 7.7), controlPoint1: NSPoint(x: 21.34, y: 7.49), controlPoint2: NSPoint(x: 21.68, y: 7.49))
        bezierPath.line(to: NSPoint(x: 22.14, y: 7.95))
        bezierPath.curve(to: NSPoint(x: 22.14, y: 8.71), controlPoint1: NSPoint(x: 22.35, y: 8.16), controlPoint2: NSPoint(x: 22.35, y: 8.5))
        bezierPath.curve(to: NSPoint(x: 20.84, y: 10.01), controlPoint1: NSPoint(x: 22.14, y: 8.71), controlPoint2: NSPoint(x: 21.37, y: 9.48))
        bezierPath.curve(to: NSPoint(x: 22.68, y: 15), controlPoint1: NSPoint(x: 21.99, y: 11.35), controlPoint2: NSPoint(x: 22.68, y: 13.1))
        bezierPath.curve(to: NSPoint(x: 15, y: 22.68), controlPoint1: NSPoint(x: 22.68, y: 19.24), controlPoint2: NSPoint(x: 19.24, y: 22.68))
        bezierPath.close()
        bezierPath.move(to: NSPoint(x: 30, y: 15))
        bezierPath.curve(to: NSPoint(x: 15, y: 0), controlPoint1: NSPoint(x: 30, y: 6.72), controlPoint2: NSPoint(x: 23.28, y: -0))
        bezierPath.curve(to: NSPoint(x: 6.03, y: 2.98), controlPoint1: NSPoint(x: 11.64, y: 0), controlPoint2: NSPoint(x: 8.53, y: 1.11))
        bezierPath.curve(to: NSPoint(x: 0, y: 15), controlPoint1: NSPoint(x: 2.37, y: 5.71), controlPoint2: NSPoint(x: 0, y: 10.08))
        bezierPath.curve(to: NSPoint(x: 15, y: 30), controlPoint1: NSPoint(x: 0, y: 23.28), controlPoint2: NSPoint(x: 6.72, y: 30))
        bezierPath.curve(to: NSPoint(x: 30, y: 15), controlPoint1: NSPoint(x: 23.28, y: 30), controlPoint2: NSPoint(x: 30, y: 23.28))
        bezierPath.close()
        backgroundColour.setFill()
        bezierPath.fill()
        
        NSGraphicsContext.restoreGraphicsState()

    }

    public dynamic class func drawPopupArrow(frame: NSRect = NSRect(x: 0, y: 3, width: 40, height: 17)) {

        //// Bezier Drawing
        let bezierPath = NSBezierPath()
        bezierPath.move(to: NSPoint(x: frame.minX, y: frame.minY))
        bezierPath.curve(to: NSPoint(x: frame.minX + 0.50000 * frame.width, y: frame.maxY - 2), controlPoint1: NSPoint(x: frame.minX + 10, y: frame.minY), controlPoint2: NSPoint(x: frame.minX + 0.36896 * frame.width, y: frame.maxY - 2))
        bezierPath.curve(to: NSPoint(x: frame.maxX, y: frame.minY), controlPoint1: NSPoint(x: frame.minX + 0.62819 * frame.width, y: frame.maxY - 2), controlPoint2: NSPoint(x: frame.maxX - 10, y: frame.minY))
        bezierPath.line(to: NSPoint(x: 40, y: 0))
        bezierPath.line(to: NSPoint(x: 0, y: 0))
        StyleKit.primary.setFill()
        bezierPath.fill()
    }

    public dynamic class func drawDisclosureTriangleOpen(frame targetFrame: NSRect = NSRect(x: 0, y: 0, width: 8, height: 8), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = NSGraphicsContext.current()!.cgContext
        
        //// Resize to Target Frame
        NSGraphicsContext.saveGraphicsState()
        let resizedFrame: NSRect = resizing.apply(rect: NSRect(x: 0, y: 0, width: 8, height: 8), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 8, y: resizedFrame.height / 8)


        //// Polygon 2 Drawing
        NSGraphicsContext.saveGraphicsState()
        context.translateBy(x: 8, y: 9)
        context.rotate(by: 180 * CGFloat.pi/180)

        let polygon2Path = NSBezierPath()
        polygon2Path.move(to: NSPoint(x: 4, y: 8))
        polygon2Path.line(to: NSPoint(x: 7.46, y: 2))
        polygon2Path.line(to: NSPoint(x: 0.54, y: 2))
        polygon2Path.close()
        NSColor.gray.setFill()
        polygon2Path.fill()

        NSGraphicsContext.restoreGraphicsState()
        
        NSGraphicsContext.restoreGraphicsState()

    }

    public dynamic class func drawDisclosureTriangleClosed(frame targetFrame: NSRect = NSRect(x: 0, y: 0, width: 8, height: 8), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = NSGraphicsContext.current()!.cgContext
        
        //// Resize to Target Frame
        NSGraphicsContext.saveGraphicsState()
        let resizedFrame: NSRect = resizing.apply(rect: NSRect(x: 0, y: 0, width: 8, height: 8), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 8, y: resizedFrame.height / 8)


        //// Polygon Drawing
        NSGraphicsContext.saveGraphicsState()
        context.translateBy(x: -1, y: 8)
        context.rotate(by: -90 * CGFloat.pi/180)

        let polygonPath = NSBezierPath()
        polygonPath.move(to: NSPoint(x: 4, y: 8))
        polygonPath.line(to: NSPoint(x: 7.46, y: 2))
        polygonPath.line(to: NSPoint(x: 0.54, y: 2))
        polygonPath.close()
        NSColor.gray.setFill()
        polygonPath.fill()

        NSGraphicsContext.restoreGraphicsState()
        
        NSGraphicsContext.restoreGraphicsState()

    }

    public dynamic class func drawRoundedRectangle(frame targetFrame: NSRect = NSRect(x: 0, y: 0, width: 50, height: 20), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = NSGraphicsContext.current()!.cgContext
        
        //// Resize to Target Frame
        NSGraphicsContext.saveGraphicsState()
        let resizedFrame: NSRect = resizing.apply(rect: NSRect(x: 0, y: 0, width: 50, height: 20), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 50, y: resizedFrame.height / 20)


        //// Rectangle Drawing
        let rectanglePath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: 50, height: 20), xRadius: 10, yRadius: 10)
        StyleKit.textGrey.setFill()
        rectanglePath.fill()
        
        NSGraphicsContext.restoreGraphicsState()

    }

    public dynamic class func drawStackViewIndicator(frame targetFrame: NSRect = NSRect(x: 0, y: 0, width: 14, height: 8), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = NSGraphicsContext.current()!.cgContext
        
        //// Resize to Target Frame
        NSGraphicsContext.saveGraphicsState()
        let resizedFrame: NSRect = resizing.apply(rect: NSRect(x: 0, y: 0, width: 14, height: 8), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 14, y: resizedFrame.height / 8)


        //// Bezier 3 Drawing
        let bezier3Path = NSBezierPath()
        bezier3Path.move(to: NSPoint(x: 0, y: 7))
        bezier3Path.line(to: NSPoint(x: 14, y: 7))
        bezier3Path.line(to: NSPoint(x: 7, y: 0))
        bezier3Path.line(to: NSPoint(x: 0, y: 7))
        bezier3Path.close()
        bezier3Path.move(to: NSPoint(x: 0, y: 7))
        bezier3Path.line(to: NSPoint(x: 14, y: 7))
        bezier3Path.line(to: NSPoint(x: 14, y: 8))
        bezier3Path.line(to: NSPoint(x: 0, y: 8))
        bezier3Path.line(to: NSPoint(x: 0, y: 7))
        bezier3Path.close()
        StyleKit.primary.setFill()
        bezier3Path.fill()
        
        NSGraphicsContext.restoreGraphicsState()

    }

    //// Generated Images

    public dynamic class func imageOfMenuIcon(imageSize: NSSize = NSSize(width: 22, height: 19), opacity: CGFloat = 1) -> NSImage {
        return NSImage(size: imageSize, flipped: true) { _ in 
            StyleKit.drawMenuIcon(frame: NSRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height), opacity: opacity)

            return true
        }
    }

    public dynamic class func imageOfMenubar(imageSize: NSSize = NSSize(width: 32, height: 32)) -> NSImage {
        return NSImage(size: imageSize, flipped: false) { _ in 
            StyleKit.drawMenubar(frame: NSRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

            return true
        }
    }

    public dynamic class func imageOfSearchIcon(selected: Bool = true) -> NSImage {
        return NSImage(size: NSSize(width: 30, height: 30), flipped: false) { _ in 
            StyleKit.drawSearchIcon(selected: selected)

            return true
        }
    }

    public dynamic class var imageOfDisclosureTriangleOpen: NSImage {
        if Cache.imageOfDisclosureTriangleOpen != nil {
            return Cache.imageOfDisclosureTriangleOpen!
        }

        Cache.imageOfDisclosureTriangleOpen = NSImage(size: NSSize(width: 8, height: 8), flipped: false) { _ in 
            StyleKit.drawDisclosureTriangleOpen()

            return true
        }

        return Cache.imageOfDisclosureTriangleOpen!
    }

    public dynamic class var imageOfDisclosureTriangleClosed: NSImage {
        if Cache.imageOfDisclosureTriangleClosed != nil {
            return Cache.imageOfDisclosureTriangleClosed!
        }

        Cache.imageOfDisclosureTriangleClosed = NSImage(size: NSSize(width: 8, height: 8), flipped: false) { _ in 
            StyleKit.drawDisclosureTriangleClosed()

            return true
        }

        return Cache.imageOfDisclosureTriangleClosed!
    }

    public dynamic class var imageOfStackViewIndicator: NSImage {
        if Cache.imageOfStackViewIndicator != nil {
            return Cache.imageOfStackViewIndicator!
        }

        Cache.imageOfStackViewIndicator = NSImage(size: NSSize(width: 14, height: 8), flipped: false) { _ in 
            StyleKit.drawStackViewIndicator()

            return true
        }

        return Cache.imageOfStackViewIndicator!
    }




    @objc(StyleKitResizingBehavior)
    public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: NSRect, target: NSRect) -> NSRect {
            if rect == target || target == NSRect.zero {
                return rect
            }

            var scales = NSSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
