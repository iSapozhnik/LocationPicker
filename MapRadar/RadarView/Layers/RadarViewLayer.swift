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
        
        let dotSize: CGFloat = 6.0
        let dotRect = CGRect(x: bounds.width / 2 - dotSize / 2, y: bounds.height / 2 - dotSize / 2, width: dotSize, height: dotSize)
        let dotPath = UIBezierPath(ovalIn: dotRect)
        
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.addPath(dotPath.cgPath)
        ctx.fillPath()
    }
}
