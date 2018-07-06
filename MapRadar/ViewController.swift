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
    @IBOutlet weak var locationPickerView: LocationPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userCoordinate = CLLocationCoordinate2DMake(48.138428, 11.615363)
        let viewRegion = MKCoordinateRegionMakeWithDistance(userCoordinate, 500, 500)
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
        
//        let region = CLCircularRegion(center: userCoordinate, radius: 100, identifier: "geofence")
//        mapView.removeOverlays(mapView.overlays)
//        let circle = MKCircle(center: userCoordinate, radius: region.radius)
//        mapView.add(circle)
        
        locationPickerView.currentRadiusInMeters = 100
        updateRadius(0.0)
        
        locationPickerView.onChangeRadiusInMeters = { [weak self] currentValue in
            self?.updateRadius(currentValue)
        }
        
        locationPickerView.onStopUpdatingRadius = { [weak self] in
            guard let center = self?.mapView.centerCoordinate, let radius = self?.locationPickerView.currentRadiusInMeters else { return }
            let viewRegion = MKCoordinateRegionMakeWithDistance(center, 2.5*radius, 2.5*radius)
            let adjustedRegion = self?.mapView.regionThatFits(viewRegion)
            self?.mapView.setRegion(adjustedRegion!, animated: true)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateRadius(locationPickerView.currentValue)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circelOverLay = overlay as? MKCircle else {return MKOverlayRenderer()}
        
        let circleRenderer = MKCircleRenderer(circle: circelOverLay)
        circleRenderer.strokeColor = .blue
        circleRenderer.lineWidth = 1.0
        circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
        return circleRenderer
    }
    
    private func zoomLevel() -> Int {
        return Int(log2(360 * (Double(mapView.bounds.width / 256) / mapView.region.span.longitudeDelta)) + 1)
    }
    
    private func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> CLLocationCoordinate2D {
        let mapPoint = MKMapPointMake(x, y)
        return MKCoordinateForMapPoint(mapPoint)
    }
    
    private func updateRadius(_ currentValue: CGFloat) {
        if (zoomLevel() < 14 ) {
            locationPickerView.isHidden = true
            return
        } else {
            locationPickerView.isHidden = false
        }
        
//        let coordinate = mapView.centerCoordinate
//
//        let minPossibleRegion = MKCoordinateRegionMakeWithDistance(coordinate, radarView.minimumRadiusInMeters, radarView.minimumRadiusInMeters)
//        let minRadius = mapView.convertRegion(minPossibleRegion, toRectTo: nil).width
//
//        let maxPossibleRegion = MKCoordinateRegionMakeWithDistance(coordinate, radarView.maximumRadiusInMeters, radarView.maximumRadiusInMeters)
//        let maxRadius = mapView.convertRegion(maxPossibleRegion, toRectTo: nil).width
//
//
//        let radius = (maxRadius - minRadius) * currentValue
//        radarView.radius = radius
//
//        return
            let regionFromRadar = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, locationPickerView.currentRadiusInMeters, locationPickerView.currentRadiusInMeters)
            let radarRect = mapView.convertRegion(regionFromRadar, toRectTo: nil)
            locationPickerView.radius = radarRect.width
    }
}

