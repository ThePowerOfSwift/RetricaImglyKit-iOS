//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

/**
   The `AlphaPickerViewDelegate` protocol defines a set of optional methods you can use to receive value-change messages for AlphaPickerView objects.
 */
@available(iOS 8, *)
@objc(IMGLYAlphaPickerViewDelegate) public protocol AlphaPickerViewDelegate {
    /**
     Is called when the alpha value changes.

     - parameter alphaPickerView: An instance of `AlphaPickerView`.
     - parameter alpha:           A value between 0.0 and 1.0.
     */
    func alphaPicked(alphaPickerView: AlphaPickerView, alpha: CGFloat)
}

/**
   The `AlphaPickerView` class defines a view that can be used to pick an alpha value.
    It displays a gradient from zero alpha to full alpha. The color of the gradient can be
    set via `color` or `hue` properties. The background is painted with a checkerboard pattern,
    that is provided by an image called "checkerboard".
 */
@available(iOS 8, *)
@objc(IMGLYAlphaPickerView) public class AlphaPickerView: UIView {

    /// The receiver’s delegate.
    /// - seealso: `AlphaPickerViewDelegate`.
    public weak var pickerDelegate: AlphaPickerViewDelegate?

    private let markerView = UIView()

    private private(set) lazy var checkboardColor: UIColor = {
        var color = UIColor.whiteColor()
        let bundle = NSBundle.imglyKitBundle
        if let image = UIImage(named: "checkerboard", inBundle: bundle, compatibleWithTraitCollection: nil) {
            color = UIColor(patternImage: image)
        }
        return color
    }()

    /// The currently choosen alpha value of the picker.
    public var alphaValue = CGFloat(0) {
        didSet {
            updateMarkerPosition()
            self.setNeedsDisplay()
        }
    }

    /// The currently choosen color value of the color gradient.
    public var color = UIColor.redColor() {
        didSet {
            alphaValue = CGColorGetAlpha(color.CGColor)
            updateMarkerPosition()
            self.setNeedsDisplay()
        }
    }

    /**
     :nodoc:
     */
    public override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        opaque = false
        backgroundColor = UIColor.clearColor()
        configureMarkerView()
    }

    private func configureMarkerView() {
        markerView.backgroundColor = UIColor.whiteColor()
        markerView.layer.shadowColor = UIColor.blackColor().CGColor
        markerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        markerView.layer.shadowOpacity = 0.25
        markerView.layer.shadowRadius = 2
        self.addSubview(markerView)
    }

    /**
     :nodoc:
     */
    public override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            drawColorSpectrum(context, rect:rect)
        }
    }

    private func drawColorSpectrum(context: CGContextRef, rect: CGRect) {
        CGContextSaveGState(context)
        PathHelper.clipCornersToOvalWidth(context, width:frame.size.width, height: frame.size.height, ovalWidth:2.0, ovalHeight:2.0)
        CGContextClip(context)
        CGContextSetFillColorWithColor(context, checkboardColor.CGColor)
        CGContextFillRect(context, self.bounds)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locs: [CGFloat] = [0.00, 1.0]
        let colors = [UIColor(hue: color.hsb.hue, saturation: color.hsb.saturation, brightness: color.hsb.brightness, alpha: 1.0).CGColor,
            UIColor(hue: color.hsb.hue, saturation: color.hsb.saturation, brightness: color.hsb.brightness, alpha: 0.0).CGColor]
        let grad = CGGradientCreateWithColors(colorSpace, colors, locs)

        CGContextDrawLinearGradient(context, grad, CGPoint(x:0, y: rect.size.height), CGPoint(x: 0, y: 0), CGGradientDrawingOptions(rawValue: 0))
        CGContextRestoreGState(context)
    }

    /**
     :nodoc:
     */
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }

    /**
     :nodoc:
     */
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }


    /**
     :nodoc:
     */
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }

    private func handleTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let pos = touch.locationInView(self)
        let p = min(max(pos.y, 0), self.frame.size.height)
        alphaValue = p / self.frame.size.height
        updateMarkerPosition()
        pickerDelegate?.alphaPicked(self, alpha: alphaValue)
        self.setNeedsDisplay()
    }

    /**
     :nodoc:
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        markerView.frame.size = CGSize(width: frame.width * 1.5, height: 4)
        markerView.center = CGPoint(x: self.frame.size.width / 2.0, y: 0)
    }

    private func updateMarkerPosition() {
        let markerY =  alphaValue * self.frame.size.height
        markerView.center = CGPoint(x: self.frame.size.width / 2.0, y: markerY)
    }
}
