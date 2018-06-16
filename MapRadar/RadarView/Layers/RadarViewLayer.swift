//
//  RadarViewLayer.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 6/16/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit
import QuartzCore

class RadarViewLayer: CALayer {
    weak var radarView: RadarView!
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        let innerBounds = bounds.insetBy(dx: radarView.borderWidth / 2.0, dy: radarView.borderWidth / 2.0)
        let path = UIBezierPath(ovalIn: innerBounds)
        
        ctx.setLineWidth(radarView.borderWidth)
        ctx.setFillColor(radarView.fillColor.cgColor)
        ctx.setStrokeColor(radarView.borderColor.cgColor)
        
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        ctx.addPath(path.cgPath)
        ctx.strokePath()
        
        let shadowWidth: CGFloat = 8.0
        let shadowHeight: CGFloat = 4.0
        let rect = CGRect(x: bounds.width / 2 - shadowWidth / 2, y: bounds.height / 2 - shadowHeight / 2, width: shadowWidth, height: shadowHeight)
        let shadowPath = UIBezierPath(ovalIn: rect)
        ctx.addPath(shadowPath.cgPath)
        ctx.setFillColor(UIColor.gray.cgColor)
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
    }
}
