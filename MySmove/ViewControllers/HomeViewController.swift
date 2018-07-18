//
//  HomeViewController.swift
//  MySmove
//
//  Created by Leonardo Parro on 14/7/18.
//  Copyright © 2018 Leonardo Parro. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    let locationManager = CLLocationManager()
    var isCurrentLocationFound = false
    var carLocations = [CarLocation]()
    var userLocation: MapPinLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        if Utils.isInternetAvailable() {
            getAllCarLocations()
        } else {
            showAlertMessage(Constants.msg_error,
                             message: Constants.msg_noInternetErr,
                             showSetting: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .authorizedAlways ||
                CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                stopLocating()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest

            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                mapView.showsUserLocation = true
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
            
        } else {
            showAlertMessage(Constants.msg_locationDisabled,
                             message: Constants.msg_enableLocationInSettings,
                             showSetting: false)
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func startLocating() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocating() {
        locationManager.stopUpdatingLocation()
    }
    
    func showPinLocationOnMap(location: MapPinLocation) {
        // car locations
        if !carLocations.isEmpty {
            carLocations.forEach { (singleCar) in
                let lat = Double(singleCar.latitude)!
                let long = Double(singleCar.longitude)!
                let isOnTrip = (singleCar.onTrip) ? "Yes" : "No"
                
                let mm = MapPinLocation(
                    title: "Car #\(singleCar.id)",
                    locationName: "On Trip: \(isOnTrip)",
                    category: .car,
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
                mapView.addAnnotation(mm)
            }
        }
        
        // user location
        mapView.addAnnotation(location)
        
        let mapCenterLocation = CLLocation(latitude: location.coordinate.latitude,
                                           longitude: location.coordinate.longitude)
        centerMapOnLocation(location: mapCenterLocation)
    }
    
    func getAllCarLocations() {
        Fetcher.sharedInstance.getAllCarLocations { (result) in
            switch result {
            case .success(let locations):
                self.carLocations.removeAll()
                self.carLocations = locations
                if self.userLocation != nil {
                    self.showPinLocationOnMap(location: self.userLocation!)
                }
                
            case .failure(let error):
                debugPrint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func showAlertMessage(_ title: String, message: String, showSetting: Bool) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if showSetting {
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(openAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - IB Actions
    @IBAction func onBookCarButtonHandler(_ sender: UIButton) {
        self.performSegue(withIdentifier: Constants.showBookingSegueId, sender: nil)
    }
}

/**************************************************************************/
// MARK: MKMapViewDelegate
/**************************************************************************/
extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapPinLocation else { return nil }

        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        if annotation.category == .car {
            annotationView!.image = UIImage(named: "baseline_local_taxi_black_18dp")
        } else if annotation.category == .user {
            annotationView!.image = UIImage(named: "baseline_person_pin_black_18dp")
        }
        
        return annotationView
    }
}

/**************************************************************************/
// MARK: CLLocationManagerDelegate
/**************************************************************************/
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startLocating()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showAlertMessage(Constants.msg_locationDisabled,
                             message: Constants.msg_enableLocationInSettings,
                             showSetting: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation = locations.last! as CLLocation
        debugPrint("current lat: \(latestLocation.coordinate.latitude), long: \(latestLocation.coordinate.longitude)")
        
        if !isCurrentLocationFound {
            isCurrentLocationFound = true
            
            userLocation = MapPinLocation(title: "I'm here",
                                            locationName: "Current Location",
                                            category: .user,
                                            coordinate: CLLocationCoordinate2D(
                                                latitude: latestLocation.coordinate.latitude,
                                                longitude: latestLocation.coordinate.longitude))
            showPinLocationOnMap(location: userLocation!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Error: \(error.localizedDescription)")
    }
}
