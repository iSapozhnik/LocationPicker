//
//  DashedLineLayer.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 6/16/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit
import QuartzCore

class DashedLine: CALayer {
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        let dashHeight: CGFloat = 2.0
        let path = UIBezierPath()
        path.move(to: CGPoint(x: dashHeight/2, y: dashHeight / 2))
        path.addLine(to: CGPoint(x: dashHeight/2, y: bounds.maxY - dashHeight / 2))
        
        let dashes: [CGFloat] = [5, 8]
        
        ctx.setLineWidth(dashHeight)
        ctx.setLineDash(phase: 0, lengths: dashes)
        ctx.setLineCap(.round)
        ctx.addPath(path.cgPath)
        ctx.setStrokeColor(RGB(r: 9, g: 82, b: 86).color.cgColor)
        ctx.strokePath()
    }
}
