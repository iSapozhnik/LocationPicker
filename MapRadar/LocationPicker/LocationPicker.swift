//
//  LocationPicker.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 6/16/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit
import MapKit

enum ThumbViewPosition {
    case bottom
    case top
    case right
    case left
}

class LocationPicker: MKAnnotationView {
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
    
    var onChangeRadiusInPoints: ((CGFloat) -> CLLocationDistance)!
    var onStartUpdatingRadius: (() -> Void)?
    var onStopUpdatingRadius: (() -> Void)?
    
    var minRadius: CGFloat = 0.0
    var maxRadius: CGFloat = 0.0
    private (set)var radius: CGFloat = Constants.defaultRadius
    
    var thumbViewPosition: ThumbViewPosition = .bottom

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
    
    private var elasticDecorator: ElasticDecorator!
    private let radarLayer = RadarViewLayer()
    private let dashedLine = DashedLine()
    
    private let draggerView = DraggerView()
    private let radiusLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        commonInit()
//    }

    func updateRadius(_ radius: CGFloat, animated: Bool) {
        self.radius = radius
        updateLayersFrame(animated: animated)
        updateViewsFrame()
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
        
        var deltaLocation: CGFloat
        switch thumbViewPosition {
        case .bottom:
            deltaLocation = CGFloat(location.y - previousLocation.y)
        case .top:
            deltaLocation = CGFloat(previousLocation.y - location.y)
        case .left:
            deltaLocation = CGFloat(previousLocation.x - location.x)
        case .right:
            deltaLocation = CGFloat(location.x - previousLocation.x)
        }
        
        previousLocation = location
        
        if draggerView.highlighted {
            
            radius += deltaLocation
            elasticDecorator.layoutControlPoints(radius: radius)

//            radius = boundValue(value: radius, minValue: minRadius, maxValue: maxRadius)
            updateRadius(radius, animated: false)

            let meters = onChangeRadiusInPoints(radius)
            let roundedMeters = 10 * (meters/10).rounded()
            currentRadiusInMeters = boundValue(value: meters, minValue: minimumRadiusInMeters, maxValue: maximumRadiusInMeters)

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
        elasticDecorator = ElasticDecorator(view: self)
        
        radarLayer.elasticDecorator = elasticDecorator
        radarLayer.radarView = self
        radarLayer.contentsScale = UIScreen.main.scale
//        radarLayer.actions = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull()]
        layer.addSublayer(radarLayer)
        
        dashedLine.contentsScale = UIScreen.main.scale
//        layer.addSublayer(dashedLine)
        
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
        draggerView.frame = thumbViewFrameFor(position: thumbViewPosition)
        
        var radiusLabelFrame = draggerView.frame
        radiusLabelFrame.origin.x = radiusLabelFrame.origin.x + draggerSize/2 + 15
        radiusLabelFrame.origin.y = radiusLabelFrame.origin.y - (draggerSize/2 + 15)
        radiusLabelFrame.size.width = 50.0
        radiusLabel.frame = radiusLabelFrame
    }
    
    private func updateLayersFrame(animated: Bool = false) {
        CATransaction.begin()
        if !animated {
            CATransaction.setDisableActions(true)
        }

        let radarFrame = CGRect(x: bounds.width / 2 - radius, y: bounds.height / 2 - radius, width: 2 * radius, height: 2 * radius)
        
        radarLayer.frame = radarFrame
        radarLayer.setNeedsDisplay()
        
        dashedLine.frame = CGRect(origin: CGPoint(x: radarFrame.midX - (Constants.defaultBorderWidth / 2), y: radarFrame.midY - (Constants.defaultBorderWidth / 2)), size: CGSize(width: 4.0, height: radius))
        dashedLine.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    private func boundValue<T>(value: T, minValue: T, maxValue: T) -> T where T: Comparable {
        return min(max(value, minValue), maxValue)
    }
    
    private func valueInMetersFrom(currentValue: Double, minInMeters: Double, maxInMeters: Double) -> Double {
        return (maxInMeters - minInMeters) * currentValue
    }
    
    private func thumbViewFrameFor(position: ThumbViewPosition) -> CGRect {
        switch position {
        case .bottom:
            return CGRect(x: bounds.width / 2 - draggerSize / 2, y: bounds.height / 2 + radius - draggerSize / 2, width: draggerSize, height: draggerSize)
        case .top:
            return CGRect(x: bounds.width / 2 - draggerSize / 2, y: bounds.height / 2 - radius - draggerSize / 2, width: draggerSize, height: draggerSize)
        case .right:
            return CGRect(x: bounds.width / 2 + radius - draggerSize / 2, y: bounds.height / 2 - draggerSize / 2, width: draggerSize, height: draggerSize)
        case .left:
            return CGRect(x: bounds.width / 2 - radius - draggerSize / 2, y: bounds.height / 2 - draggerSize / 2, width: draggerSize, height: draggerSize)
        }
    }
}
