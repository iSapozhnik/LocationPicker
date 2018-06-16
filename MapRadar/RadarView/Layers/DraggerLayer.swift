//
//  DraggerLayer.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 6/16/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit
import QuartzCore

class DraggerLayer: CALayer {
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        let path = UIBezierPath(ovalIn: bounds.insetBy(dx: 4, dy: 4))
        
        ctx.setFillColor(UIColor.white.cgColor)
        
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: 2), blur: 3.0, color: UIColor.black.withAlphaComponent(0.3).cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        ctx.restoreGState()
        
        let dotSize = bounds.width * 20 / 100
        let dotRect = CGRect(x: bounds.width / 2 - dotSize / 2, y: bounds.height / 2 - dotSize / 2, width: dotSize, height: dotSize)
        let dotPath = UIBezierPath(ovalIn: dotRect)
        
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.addPath(dotPath.cgPath)
        ctx.fillPath()
    }
}
