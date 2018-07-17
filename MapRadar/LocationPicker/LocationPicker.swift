//
//  LocationPicker.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 6/16/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit
import MapKit

class LocationPicker: UIView {
    private struct Constants {
        static let defaultStrokeColor = RGB(r: 9, g: 82, b: 86).color
        static let defaultFillColor = RGB(r: 8, g: 127, b: 140).color.withAlphaComponent(0.3)
        static let defaultRadius: CGFloat = 75.0
        static let defaultBorderWidth: CGFloat = 2.0
        static let defaultDraggerSize: CGFloat = 30.0
    }
    
    var minimumRadiusInMeters: Double = 100
    var maximumRadiusInMeters: Double = 1100
    var currentRadiusInMeters: Double = 100
    
    var minimumValue: CGFloat = 0.0
    var maximumValue: CGFloat = 1.0
    var currentValue: CGFloat = 0.11
    
    
    var onChangeRadiusInMeters: ((CGFloat) -> Void)? = nil
    var onChangeRadiusInPoints: ((CGFloat) -> CLLocationDistance)!
    var onStartUpdatingRadius: (() -> Void)?
    var onStopUpdatingRadius: (() -> Void)?
    
    var minRadius: CGFloat = 0.0
    var maxRadius: CGFloat = 0.0
    var radius: CGFloat = Constants.defaultRadius {
        didSet {
            updateLayersFrame()
            updateViewsFrame()
        }
    }
    var borderWidth: CGFloat = Constants.defaultBorderWidth {
        didSet {
            radarLayer.setNeedsDisplay()
        }
    }
    var borderColor: UIColor = Constants.defaultStrokeColor {
        didSet {
            radarLayer.setNeedsDisplay()
        }
    }
    var fillColor: UIColor = Constants.defaultFillColor {
        didSet {
            radarLayer.setNeedsDisplay()
        }
    }
    var draggerSize: CGFloat = Constants.defaultDraggerSize {
        didSet {
            updateViewsFrame()
        }
    }
    
    var previousLocation = CGPoint()
    
    private let radarLayer = RadarViewLayer()
    private let dashedLine = DashedLine()
    
    private let draggerView = DraggerView()
    private let radiusLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        previousLocation = touch.location(in: self)
        
        if draggerView.frame.contains(previousLocation) {
            onStartUpdatingRadius?()
            
            UIView.animate(withDuration: 0.3) {
                self.radiusLabel.alpha = 1.0
            }
            
            draggerView.highlighted = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        let deltaLocation = CGFloat(location.y - previousLocation.y)
//        let deltaValue = (maximumValue - minimumValue) * deltaLocation / CGFloat(radarLayer.bounds.height - draggerSize)
        
        previousLocation = location
        
        if draggerView.highlighted {
            radius += deltaLocation
//            currentValue += deltaValue
//            currentValue = boundValue(value: currentValue, minValue: minimumValue, maxValue: maximumValue)

//            print("Current value: \(currentValue)")
//            print("Delta value: \(deltaLocation)")

            let meters = onChangeRadiusInPoints(radius)
            let roundedMeters = 10 * (meters/10).rounded()
            currentRadiusInMeters = meters//min(max(minimumRadiusInMeters, meters), maximumRadiusInMeters)


//            currentRadiusInMeters = min(max(minimumRadiusInMeters, (maximumRadiusInMeters - minimumRadiusInMeters) * Double(currentValue)), maximumRadiusInMeters)

            radiusLabel.text = "\(Int(roundedMeters)) m"
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        onStopUpdatingRadius?()

        UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
            self.radiusLabel.alpha = 0.0
        }, completion: nil)
        draggerView.highlighted = false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if clipsToBounds || isHidden || alpha == 0 { return nil }
        
        if draggerView.frame.contains(point) {
            return draggerView
        }
        return nil
    }
    
    private func commonInit() {
        radarLayer.radarView = self
        radarLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(radarLayer)
        
        dashedLine.contentsScale = UIScreen.main.scale
        layer.addSublayer(dashedLine)
        
        draggerView.isUserInteractionEnabled = false
        addSubview(draggerView)
        
        radiusLabel.textColor = .white
        radiusLabel.text = "\(Int(currentRadiusInMeters)) m"
        radiusLabel.layer.cornerRadius = 3.0
        radiusLabel.alpha = 0.0
        radiusLabel.layer.masksToBounds = true
        radiusLabel.backgroundColor = .black
        radiusLabel.textAlignment = .center
        radiusLabel.font = UIFont.systemFont(ofSize: 12)
        addSubview(radiusLabel)
        
        updateViewsFrame()
        updateLayersFrame()
    }
    
    private func updateViewsFrame() {
        let draggerFrame = CGRect(x: bounds.width / 2 - draggerSize / 2, y: bounds.height / 2 + radius - draggerSize / 2, width: draggerSize, height: draggerSize)
        draggerView.frame = draggerFrame
        
        var radiusLabelFrame = draggerFrame
        radiusLabelFrame.origin.x = radiusLabelFrame.origin.x + draggerSize/2 + 15
        radiusLabelFrame.origin.y = radiusLabelFrame.origin.y - (draggerSize/2 + 15)
        radiusLabelFrame.size.width = 50.0
        radiusLabel.frame = radiusLabelFrame
    }
    
    private func updateLayersFrame() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let radarFrame = CGRect(x: bounds.width / 2 - radius, y: bounds.height / 2 - radius, width: 2 * radius, height: 2 * radius)
        
        radarLayer.frame = radarFrame
        radarLayer.setNeedsDisplay()
        
        dashedLine.frame = CGRect(origin: CGPoint(x: radarFrame.midX - (Constants.defaultBorderWidth / 2), y: radarFrame.midY - (Constants.defaultBorderWidth / 2)), size: CGSize(width: 4.0, height: radius))
        dashedLine.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    private func boundValue(value: CGFloat, minValue: CGFloat, maxValue: CGFloat) -> CGFloat {
        return min(max(value, minValue), maxValue)
    }
    
    private func valueInMetersFrom(currentValue: Double, minInMeters: Double, maxInMeters: Double) -> Double {
        return (maxInMeters - minInMeters) * currentValue
    }
}
