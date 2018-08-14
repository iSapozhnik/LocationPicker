//
//  UIView+Extensions.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 8/12/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit

extension UIView {
    func lp_center(usePresentationIfPossible: Bool) -> CGPoint {
        if usePresentationIfPossible, let presentation = layer.presentation() {
            return presentation.position
        }
        return center
    }
}
