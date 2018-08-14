//
//  RadarViewLayer.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 6/16/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit
import QuartzCore

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class RadarViewLayer: CALayer {
    weak var radarView: LocationPicker!
    weak var elasticDecorator: ElasticDecorator!
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        let pi = Double.pi
        let innerBounds = bounds.insetBy(dx: radarView.borderWidth / 2.0, dy: radarView.borderWidth / 2.0)
        
        let path = UIBezierPath()
        
        let l1ControlPointView = elasticDecorator.l1ControlPointView
        let l2ControlPointView = elasticDecorator.l2ControlPointView
        let r1ControlPointView = elasticDecorator.r1ControlPointView
        let r2ControlPointView = elasticDecorator.r2ControlPointView
        let cControlPointView = elasticDecorator.cControlPointView
        
        path.addArc(withCenter: CGPoint(x: innerBounds.width / 2, y: innerBounds.height / 2), radius: innerBounds.width / 2 - radarView.borderWidth / 2.0, startAngle: CGFloat(pi), endAngle: 0, clockwise: true)
//        path.addArc(withCenter: CGPoint(x: innerBounds.width / 2, y: innerBounds.height / 2), radius: innerBounds.width / 2 - radarView.borderWidth / 2.0, startAngle: 0, endAngle: CGFloat(pi), clockwise: true)
        
        path.addCurve(to: cControlPointView.lp_center(usePresentationIfPossible: false), controlPoint1: r2ControlPointView.lp_center(usePresentationIfPossible: false), controlPoint2: r1ControlPointView.lp_center(usePresentationIfPossible: false))
//        path.addCurve(to: CGPoint(x: innerBounds.width, y: innerBounds.height / 2), controlPoint1: r1ControlPointView.lp_center(usePresentationIfPossible: false), controlPoint2: r2ControlPointView.lp_center(usePresentationIfPossible: false))
//        path.close()
        
        
//        path.addCurve(to: <#T##CGPoint#>, controlPoint1: <#T##CGPoint#>, controlPoint2: <#T##CGPoint#>)
//        path.addLineToPoint(CGPoint(x: 0.0, y: l3ControlPointView.dg_center(false).y))
//        path.addCurveToPoint(l1ControlPointView.dg_center(false), controlPoint1: l3ControlPointView.dg_center(false), controlPoint2: l2ControlPointView.dg_center(false))
        
        
//        let path = UIBezierPath(ovalIn: innerBounds)

        ctx.setLineWidth(radarView.borderWidth)
        ctx.setFillColor(radarView.fillColor.cgColor)
        ctx.setStrokeColor(radarView.borderColor.cgColor)
        
//        ctx.addPath(path.cgPath)
//        ctx.fillPath()
        
        ctx.addPath(path.cgPath)
        ctx.strokePath()
        
        /*
        let shadowWidth: CGFloat = 8.0
        let shadowHeight: CGFloat = 4.0
        let rect = CGRect(x: bounds.width / 2 - shadowWidth / 2, y: bounds.height / 2 - shadowHeight / 2, width: shadowWidth, height: shadowHeight)
        let shadowPath = UIBezierPath(ovalIn: rect)
        ctx.addPath(shadowPath.cgPath)
        ctx.setFillColor(UIColor.darkGray.cgColor)
        ctx.fillPath()
        
        let pinHeight: CGFloat = 20.0
        
        let pinPath = UIBezierPath()
        pinPath.move(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2))
        pinPath.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2 - pinHeight))
        
        ctx.setLineCap(.round)
        ctx.setLineWidth(1.0)
        ctx.setStrokeColor(UIColor.gray.cgColor)
        ctx.addPath(pinPath.cgPath)
        ctx.strokePath()
        
        let dotSize: CGFloat = 6.0
        let dotRect = CGRect(x: bounds.width / 2 - dotSize / 2, y: bounds.height / 2 - dotSize / 2 - pinHeight, width: dotSize, height: dotSize)
        let dotPath = UIBezierPath(ovalIn: dotRect)
        
        ctx.setFillColor(RGB(r: 242, g: 65, b: 65).color.cgColor)
        ctx.setStrokeColor(RGB(r: 201, g: 7, b: 7).color.cgColor)

        ctx.addPath(dotPath.cgPath)
        ctx.setLineWidth(1.0)
        ctx.fillPath()
        ctx.addPath(dotPath.cgPath)
        ctx.strokePath()
 */
    }
}
