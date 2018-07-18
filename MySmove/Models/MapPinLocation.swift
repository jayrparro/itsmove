//
//  MapPinLocation.swift
//  MySmove
//
//  Created by Leonardo Parro on 14/7/18.
//  Copyright © 2018 Leonardo Parro. All rights reserved.
//

import Foundation
import MapKit

enum MapPinType: String {
    case user = "User"
    case car = "Car"
    case booking = "Booking"
}

class MapPinLocation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String?
    let category: MapPinType
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, category: MapPinType, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.category = category
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
