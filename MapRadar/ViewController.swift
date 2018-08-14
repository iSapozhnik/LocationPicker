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

class LocationPickerAnnotation: MKPointAnnotation {}

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationPickerView: LocationPicker!
    @IBOutlet weak var coordinateLabel: UILabel!

    let initialCoordinate = CLLocationCoordinate2DMake(48.138428, 11.615363)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationPickerView.frame = mapView.bounds
        locationPickerView.updateRadius(150.0, animated: false)
        locationPickerView.minRadius = 30.0
        let padding: CGFloat = 5.0
        locationPickerView.maxRadius = UIScreen.main.bounds.width / 2 - padding

        let viewRegion = MKCoordinateRegionMakeWithDistance(initialCoordinate, 500, 500)
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)

//        let region = CLCircularRegion(center: initialCoordinate, radius: 5, identifier: "geofence")
//        mapView.removeOverlays(mapView.overlays)
//        let circle = MKCircle(center: initialCoordinate, radius: region.radius)
//        mapView.add(circle)
        
        let annotation = LocationPickerAnnotation()
        annotation.coordinate = initialCoordinate
        mapView.addAnnotation(annotation)

        locationPickerView.onChangeRadiusInPoints = { [weak self] radiusInPoints in
            self?.locationPickerView.frame = self!.mapView.bounds

            let centerPoint = self!.mapView.convert(self!.locationPickerView.center, toCoordinateFrom: self!.locationPickerView)
            let centerBottomPoint = self!.mapView.convert(CGPoint(x: self!.locationPickerView.center.x, y: self!.locationPickerView.center.y + radiusInPoints), toCoordinateFrom: self!.locationPickerView)
            return centerPoint.distance(from: centerBottomPoint)
        }
        
        locationPickerView.onStopUpdatingRadius = { [weak self] in
            guard let mapView = self?.mapView, let radiusInMeters = self?.locationPickerView.currentRadiusInMeters else { return }

            var point = self!.locationPickerView.center

            let center = mapView.convert(point, toCoordinateFrom: nil)
            let viewRegion = MKCoordinateRegionMakeWithDistance(center, 4 * radiusInMeters, 4 * radiusInMeters)
            let adjustedRegion = self?.mapView.regionThatFits(viewRegion)
            self?.mapView.setRegion(adjustedRegion!, animated: false)

            let initialCoordinate = self!.initialCoordinate
//            self?.coordinateLabel.text = (mapView.centerCoordinate.latitude == initialCoordinate.latitude) && (mapView.centerCoordinate.longitude == initialCoordinate.longitude) ? "The same" : "Not the same"
            self?.checkCoordinates()
        }
    }

    func checkCoordinates() {
        let rect = mapView.convertRegion(MKCoordinateRegionMakeWithDistance(initialCoordinate, 0.5, 0.5), toRectTo: nil)
        let point = mapView.convert(mapView.centerCoordinate, toPointTo: nil)

        coordinateLabel.text = rect.contains(point) ? "The same" : "Not the same"

        print("initial: \(initialCoordinate)\n current: \(mapView.centerCoordinate)\ndistance: \(initialCoordinate.distance(from: mapView.centerCoordinate))")
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateRadius(locationPickerView.radius)
        checkCoordinates()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: LocationPickerAnnotation.self) {
            return locationPickerView
        }
        
        return nil
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

        let regionFromRadar = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, locationPickerView.currentRadiusInMeters, locationPickerView.currentRadiusInMeters)
        let radarRect = mapView.convertRegion(regionFromRadar, toRectTo: locationPickerView)
        locationPickerView.updateRadius(radarRect.width, animated: true)
        locationPickerView.elasticDecorator.layoutControlPoints(radius: radarRect.width)
    }
}

