//
//  LocationPickerRenderer.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 06.07.18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import MapKit

class LocationPickerRenderer: MKCircleRenderer {
    let draggerLayer = DraggerLayer()

    override init(circle: MKCircle) {
        super.init(circle: circle)


    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {

        super.draw(mapRect, zoomScale: zoomScale, in: context)

        let mPoint = MKMapPointForCoordinate(self.overlay.coordinate)
        let mapPointPerMeter = MKMapPointsPerMeterAtLatitude(self.overlay.coordinate.latitude)
        let radius: Double = 200 * Double(mapPointPerMeter)

        let mapRectBounds = MKMapRectMake(mPoint.x, mPoint.y, radius * 2, radius * 2)
        let bounds = rect(for: mapRectBounds)

        let draggerWidth: Double = 30
        let draggerSize = CGSize(width: CGFloat(draggerWidth * mapPointPerMeter), height: CGFloat(draggerWidth * mapPointPerMeter))
        let draggerBounds = CGRect(origin: bounds.origin, size: draggerSize)
/*
        context.setStrokeColor(UIColor.red.cgColor)
        context.setFillColor(UIColor.red.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(2)
        context.setShouldAntialias(true)

        context.addArc(center: CGPoint(x: bounds.origin.x, y: bounds.origin.y), radius: CGFloat(radius), startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        context.drawPath(using: .fill)

        UIGraphicsPopContext()
*/
        let path = UIBezierPath(ovalIn: draggerBounds.insetBy(dx: 4, dy: 4))

        context.setFillColor(UIColor.white.cgColor)

        context.saveGState()
        context.setShadow(offset: CGSize(width: 0, height: 2), blur: 3.0, color: UIColor.black.withAlphaComponent(0.3).cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        context.restoreGState()

        let dotSize = draggerBounds.width * 20 / 100
        let dotRect = CGRect(x: draggerBounds.width / 2 - dotSize / 2, y: draggerBounds.height / 2 - dotSize / 2, width: dotSize, height: dotSize)
        let dotPath = UIBezierPath(ovalIn: dotRect)

        context.setFillColor(UIColor.black.cgColor)
        context.addPath(dotPath.cgPath)
        context.fillPath()
        context.drawPath(using: .fill)
    }
}
