//
//  ViewController.swift
//  MapRadar
//
//  Created by Ivan Sapozhnik on 6/16/18.
//  Copyright © 2018 Ivan Sapozhnik. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation : NSObject, MKAnnotation {
    dynamic var coordinate : CLLocationCoordinate2D
    var title: String!
    var subtitle: String!

    init(location coord:CLLocationCoordinate2D) {
        self.coordinate = coord
        super.init()
    }
}

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination = CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationPickerView: LocationPicker!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var editMode: UISwitch!
    var annotationLocationPickerView: LocationPicker!
    var annotation: LocationAnnotation!


    let initialCoordinate = CLLocationCoordinate2DMake(48.138428, 11.615363)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePan))
        mapView.addGestureRecognizer(panGesture)
        panGesture.delegate = self

        syncRadius(150.0)
//        locationPickerView.updateRadius(150.0, animated: false)
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

        let annotation = LocationAnnotation(location: initialCoordinate)
        mapView.addAnnotation(annotation)
        self.annotation = annotation

        locationPickerView.onChangeRadiusInPoints = { [weak self] radiusInPoints in
            let centerPoint = self!.mapView.convert(self!.locationPickerView.center, toCoordinateFrom: self!.locationPickerView)
            let centerBottomPoint = self!.mapView.convert(CGPoint(x: self!.locationPickerView.center.x, y: self!.locationPickerView.center.y + radiusInPoints), toCoordinateFrom: self!.locationPickerView)
            return centerPoint.distance(from: centerBottomPoint)
        }
        
        locationPickerView.onStopUpdatingRadius = { [weak self] in
            guard let mapView = self?.mapView, let radiusInMeters = self?.locationPickerView.currentRadiusInMeters else { return }

            var point = self!.locationPickerView.center
//            point.y -= 20

            let center = mapView.convert(point, toCoordinateFrom: nil)
            let viewRegion = MKCoordinateRegionMakeWithDistance(center, 4 * radiusInMeters, 4 * radiusInMeters)
            let adjustedRegion = self?.mapView.regionThatFits(viewRegion)
            self?.mapView.setRegion(adjustedRegion!, animated: false)

            let initialCoordinate = self!.initialCoordinate
//            self?.coordinateLabel.text = (mapView.centerCoordinate.latitude == initialCoordinate.latitude) && (mapView.centerCoordinate.longitude == initialCoordinate.longitude) ? "The same" : "Not the same"
            self?.checkCoordinates()
        }
    }

    func syncRadius(_ radius: CGFloat) {
        if annotationLocationPickerView != nil {
            annotationLocationPickerView.updateRadius(radius, animated: false)
        }
        locationPickerView.updateRadius(radius, animated: false)
    }

    @objc func handlePan(sender: UIPanGestureRecognizer) {
        if annotationLocationPickerView.interacting, !editMode.isOn {
            return
        }
        switch sender.state {
        case .began:
            locationPickerView.alpha = 1.0
            annotationLocationPickerView.alpha = 0.0
            break
        case .changed:
            break
        case .ended:
            break
//            self.annotation.coordinate = self.mapView.centerCoordinate
//            locationPickerView.alpha = 0.0
//            annotationLocationPickerView.alpha = 1.0

        default:
            break
        }
    }

    @IBAction func onChangeLocationPickerMode(_ sender: UISwitch) {
        annotationLocationPickerView.hideDragger(sender.isOn)
        locationPickerView.hideDragger(sender.isOn)

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
        if annotation != nil {
            self.annotation.coordinate = self.mapView.centerCoordinate
        }
        if annotationLocationPickerView != nil {
            annotationLocationPickerView.alpha = 1.0

        }
        locationPickerView.alpha = 0.0
        checkCoordinates()
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circelOverLay = overlay as? MKCircle else {return MKOverlayRenderer()}

        let circleRenderer = MKCircleRenderer(circle: circelOverLay)
        circleRenderer.strokeColor = .blue
        circleRenderer.lineWidth = 1.0
        circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
        return circleRenderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        // Better to make this class property
        let annotationIdentifier = "LocationPickerAnnotationView"

        var annotationView: LocationPicker?
        guard let locationPicker = self.annotationLocationPickerView else {
            let locationPicker = LocationPicker(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            locationPicker.frame = mapView.bounds
            locationPicker.minRadius = 40.0
            locationPicker.maxRadius = 200.0
            locationPicker.minimumRadiusInMeters = 50.0
            locationPicker.maximumRadiusInMeters = 1000.0
            self.annotationLocationPickerView = locationPicker

            locationPicker.onChangeRadiusInPoints = { [weak self] radiusInPoints in
                let centerPoint = annotation.coordinate
                let centerBottomPoint = self!.mapView.convert(CGPoint(x: locationPicker.center.x, y: locationPicker.center.y + radiusInPoints), toCoordinateFrom: locationPicker)
                return centerPoint.distance(from: centerBottomPoint)
            }

            locationPicker.onStopUpdatingRadius = { [weak self] in
                guard let mapView = self?.mapView, let radiusInMeters = self?.locationPickerView.currentRadiusInMeters else { return }

                var point = self!.locationPickerView.center
                //            point.y -= 20

                let center = annotation.coordinate
                let viewRegion = MKCoordinateRegionMakeWithDistance(center, 4 * radiusInMeters, 4 * radiusInMeters)
                let adjustedRegion = self?.mapView.regionThatFits(viewRegion)
                self?.mapView.setRegion(adjustedRegion!, animated: false)
            }

            return locationPicker
        }
        return locationPicker
//        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
//            annotationView = dequeuedAnnotationView
//            annotationView?.annotation = annotation
//        }
//        else {
//            let lp = LocationPicker(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            annotationView = av
//        }
//
//        if let annotationView = annotationView {
//            // Configure your annotation view here
//            annotationView.canShowCallout = true
//        }
//
//        return annotationView
    }

    private func zoomLevel() -> Int {
        return Int(log2(360 * (Double(mapView.bounds.width / 256) / mapView.region.span.longitudeDelta)) + 1)
    }
    
    private func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> CLLocationCoordinate2D {
        let mapPoint = MKMapPointMake(x, y)
        return MKCoordinateForMapPoint(mapPoint)
    }
    
    private func updateRadius(_ currentValue: CGFloat) {
        guard let annotationLocationPickerView = self.annotationLocationPickerView else { return }
        let regionFromRadar = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, annotationLocationPickerView.currentRadiusInMeters, annotationLocationPickerView.currentRadiusInMeters)
        let radarRect = mapView.convertRegion(regionFromRadar, toRectTo: locationPickerView)
        syncRadius(radarRect.width)
//        annotationLocationPickerView.updateRadius(radarRect.width, animated: true)
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

