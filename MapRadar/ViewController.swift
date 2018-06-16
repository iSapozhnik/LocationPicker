//
//  ViewController.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 6/16/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radarView: RadarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userCoordinate = CLLocationCoordinate2DMake(48.138428, 11.615363)
        let viewRegion = MKCoordinateRegionMakeWithDistance(userCoordinate, 500, 500)
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
        
        radarView.onChangeRadiusInMeters = { [weak self] in
            self?.updateRadius()
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateRadius()
    }
    
    private func zoomLevel() -> Int {
        return Int(log2(360 * (Double(mapView.bounds.width / 256) / mapView.region.span.longitudeDelta)) + 1)
    }
    
    private func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> CLLocationCoordinate2D {
        let mapPoint = MKMapPointMake(x, y)
        return MKCoordinateForMapPoint(mapPoint)
    }
    
    private func updateRadius() {
        if (zoomLevel() < 14 ) {
            radarView.isHidden = true
            return
        } else {
            radarView.isHidden = false
        }
        
        let regionFromRadar = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, radarView.currentRadiusInMeters, radarView.currentRadiusInMeters)
        let radarRect = mapView.convertRegion(regionFromRadar, toRectTo: nil)
        radarView.radius = radarRect.width
    }
}

