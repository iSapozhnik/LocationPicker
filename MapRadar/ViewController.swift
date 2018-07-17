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
//
//            let center = MKMapPointForCoordinate(centerPoint)
//            let bottom = MKMapPointForCoordinate(centerBottomPoint)
//
//            return MKMetersBetweenMapPoints(center, bottom)

//            let centerLocation = CLLocation(latitude: centerPoint.latitude, longitude: centerPoint.longitude)
//            print("centerLocation = \(centerLocation)")
//
//            let bottomCenterLocation = CLLocation(latitude: centerBottomPoint.latitude, longitude: centerBottomPoint.longitude)
//
//            let radius =  CLLocationDistance(bottomCenterLocation.distance(to: centerLocation))
//
//            return radius
        }
        
        locationPickerView.onStopUpdatingRadius = { [weak self] in
            guard let mapView = self?.mapView, let radiusInMeters = self?.locationPickerView.currentRadiusInMeters else { return }

            let viewRegion = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, 3 * radiusInMeters, 3 * radiusInMeters)
            let adjustedRegion = self?.mapView.regionThatFits(viewRegion)
            self?.mapView.setRegion(adjustedRegion!, animated: true)
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
        if (zoomLevel() < 14 ) {
            locationPickerView.isHidden = true
            return
        } else {
            locationPickerView.isHidden = false
        }

        let regionFromRadar = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, locationPickerView.currentRadiusInMeters, locationPickerView.currentRadiusInMeters)
        let radarRect = mapView.convertRegion(regionFromRadar, toRectTo: locationPickerView)
        locationPickerView.updateRadius(radarRect.width, animated: true)
    }
}

