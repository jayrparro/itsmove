//
//  ViewController.swift
//  MySmove
//
//  Created by Leonardo Parro on 9/7/18.
//  Copyright © 2018 Leonardo Parro. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //getAllCarLocations()
        //getBookingAvailability()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func getAllCarLocations() {
        Fetcher.sharedInstance.getAllCarLocations { (result) in
            switch result {
            case .success(let locations):
                print("Locations: \(locations)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getBookingAvailability() {
        let startTime = "1531134000"
        let endTime = "1531137600"
        
        Fetcher.sharedInstance.getBookingAvailability(
            startTime: startTime,
            endTime: endTime) { (result) in
                switch result {
                case .success(let bookings):
                    print("Bookings: \(bookings)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
        }
    }
}

