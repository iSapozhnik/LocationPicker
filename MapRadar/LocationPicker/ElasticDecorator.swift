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
    
    let l2ControlPointView = UIView()
    let l1ControlPointView = UIView()
    let cControlPointView = UIView()
    let r1ControlPointView = UIView()
    let r2ControlPointView = UIView()
    
    init(view: UIView) {
        self.view = view
        commonInit()
    }
    
    func layoutControlPoints(radius: CGFloat) {
        let const: CGFloat = 0.552284749831
        let center = view.center

        l2ControlPointView.center = CGPoint(x: center.x - radius , y: center.y + radius * const)
        l1ControlPointView.center = CGPoint(x: center.x - radius * const , y: center.y + radius)
        
//        r1ControlPointView.center = CGPoint(x: center.x + radius * const , y: center.y + radius)
//        r2ControlPointView.center = CGPoint(x: center.x + radius, y: center.y + radius * const)

        r1ControlPointView.center = CGPoint(x: center.x + radius , y: center.y + radius * const)
        r2ControlPointView.center = CGPoint(x: center.x + radius, y: center.y)
        
        cControlPointView.center = CGPoint(x: center.x , y: center.y + radius)
    }
    
    private func commonInit() {
        l2ControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
        l1ControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
        cControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
        r1ControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
        r2ControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
        
        l2ControlPointView.backgroundColor = .blue
        l1ControlPointView.backgroundColor = .blue
        cControlPointView.backgroundColor = .red
        r1ControlPointView.backgroundColor = .red
        r2ControlPointView.backgroundColor = .black
        
        view.addSubview(l2ControlPointView)
        view.addSubview(l1ControlPointView)
        view.addSubview(cControlPointView)
        view.addSubview(r1ControlPointView)
        view.addSubview(r2ControlPointView)
    }
}
