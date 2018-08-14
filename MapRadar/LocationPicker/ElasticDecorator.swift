//
//  ElasticDecorator.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 8/12/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit

class ElasticDecorator {
    private weak var view: UIView!

    var p0 = CGPoint.zero
    var p1 = CGPoint.zero
    var p2 = CGPoint.zero
    var p3 = CGPoint.zero

    let c0l = UIView()
    let c0r = UIView()

    let c1t = UIView()
    let c1b = UIView()

    let c2l = UIView()
    let c2r = UIView()

    let c3t = UIView()
    let c3b = UIView()
    
    init(view: UIView) {
        self.view = view
        commonInit()
    }

    func layoutControlPoints(radius: CGFloat, offset: CGFloat = 0.0) {
        let r = radius
        let d = 2 * r

        p0 = CGPoint(x: r, y: offset)
        p1 = CGPoint(x: d, y: r)
        p2 = CGPoint(x: r, y: d)
        p3 = CGPoint(x: 0, y: r)

        let n: Double = 4

        let const: CGFloat = CGFloat((4/3)*tan(M_PI/(2*n))) //0.552284749831
        let cpLenght = r * const

        c0l.center = CGPoint(x: r - cpLenght - pow(abs(offset), 0.1), y: p0.y)
        c0r.center = CGPoint(x: r + cpLenght + pow(abs(offset), 0.1), y: p0.y)

        c1t.center = CGPoint(x: p1.x, y: r - cpLenght)
        c1b.center = CGPoint(x: p1.x, y: r + cpLenght)

        c2r.center = CGPoint(x: r + cpLenght, y: p2.y)
        c2l.center = CGPoint(x: r - cpLenght, y: p2.y)

        c3b.center = CGPoint(x: p3.x, y: r + cpLenght)
        c3t.center = CGPoint(x: p3.x, y: r - cpLenght)
    }

    func path() -> UIBezierPath {
        let cp0l = c0l.lp_center()
        let cp0r = c0r.lp_center()

        let cp1t = c1t.lp_center()
        let cp1b = c1b.lp_center()

        let cp2l = c2l.lp_center()
        let cp2r = c2r.lp_center()

        let cp3t = c3t.lp_center()
        let cp3b = c3b.lp_center()

        let path = UIBezierPath()

        path.move(to: p0)
        path.addCurve(to: p1, controlPoint1: cp0r, controlPoint2: cp1t)
        path.addCurve(to: p2, controlPoint1: cp1b, controlPoint2: cp2r)
        path.addCurve(to: p3, controlPoint1: cp2l, controlPoint2: cp3b)
        path.addCurve(to: p0, controlPoint1: cp3t, controlPoint2: cp0l)
        return path
    }
    
    private func commonInit() {
        let controlPoints = [c0l, c0r, c1t, c1b, c2l, c2r, c3t, c3b]

        controlPoints.forEach { controlPoint in
            controlPoint.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
            controlPoint.backgroundColor = .red
            view.addSubview(controlPoint)
        }
    }
}
