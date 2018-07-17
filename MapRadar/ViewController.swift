//
//  ViewController.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 6/16/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit
import MapKit

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination = CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationPickerView: LocationPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationPickerView.updateRadius(150.0, animated: false)
        locationPickerView.minRadius = 30.0
        let padding: CGFloat = 5.0
        locationPickerView.maxRadius = UIScreen.main.bounds.width / 2 - padding

        let userCoordinate = CLLocationCoordinate2DMake(48.138428, 11.615363)
        let viewRegion = MKCoordinateRegionMakeWithDistance(userCoordinate, 500, 500)
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
//
//        let region = CLCircularRegion(center: userCoordinate, radius: 100, identifier: "geofence")
//        mapView.removeOverlays(mapView.overlays)
//        let circle = MKCircle(center: userCoordinate, radius: region.radius)
//        mapView.add(circle)

        locationPickerView.onChangeRadiusInPoints = { [weak self] radiusInPoints in
            let centerPoint = self!.mapView.convert(self!.locationPickerView.center, toCoordinateFrom: self!.locationPickerView)
            let centerBottomPoint = self!.mapView.convert(CGPoint(x: self!.locationPickerView.center.x, y: self!.locationPickerView.center.y + radiusInPoints), toCoordinateFrom: self!.locationPickerView)
            return centerPoint.distance(from: centerBottomPoint)
        }
        
        locationPickerView.onStopUpdatingRadius = { [weak self] in
            guard let mapView = self?.mapView, let radiusInMeters = self?.locationPickerView.currentRadiusInMeters else { return }

            let viewRegion = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, 4 * radiusInMeters, 4 * radiusInMeters)
            let adjustedRegion = self?.mapView.regionThatFits(viewRegion)
            self?.mapView.setRegion(adjustedRegion!, animated: false)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateRadius(locationPickerView.radius)
    }

    private func zoomLevel() -> Int {
        return Int(log2(360 * (Double(mapView.bounds.width / 256) / mapView.region.span.longitudeDelta)) + 1)
    }
    
    private func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> CLLocationCoordinate2D {
        let mapPoint = MKMapPointMake(x, y)
        return MKCoordinateForMapPoint(mapPoint)
    }
    
    private func updateRadius(_ currentValue: CGFloat) {

        let regionFromRadar = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, locationPickerView.currentRadiusInMeters, locationPickerView.currentRadiusInMeters)
        let radarRect = mapView.convertRegion(regionFromRadar, toRectTo: locationPickerView)
        locationPickerView.updateRadius(radarRect.width, animated: true)
    }
}

