//
//  DraggerView.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 6/16/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit

class DraggerView: UIView {
    private struct Constants {
        static let defaultFillColor = UIColor.white
    }
    var highlighted = false
    var fillColor: UIColor = Constants.defaultFillColor {
        didSet {
            draggerLayer.setNeedsDisplay()
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateLayersFrame()
        }
    }
    
    private let draggerLayer = DraggerLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    private func commonInit() {
        draggerLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(draggerLayer)
        
        updateLayersFrame()
    }
    
    private func updateLayersFrame() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        draggerLayer.frame = bounds
        draggerLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
}
