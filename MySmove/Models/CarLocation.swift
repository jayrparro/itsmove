//
//  CarLocation.swift
//  MySmove
//
//  Created by Leonardo Parro on 9/7/18.
//  Copyright © 2018 Leonardo Parro. All rights reserved.
//

import Foundation
import MapKit

struct CarLocationList: Codable {
    let locations: [CarLocation]
    
    enum CodingKeys: String, CodingKey {
        case locations = "data"
    }
}

struct CarLocation: Codable {    
    let id: Int
    let latitude: String
    let longitude: String    
    let onTrip: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case onTrip = "is_on_trip"
    }
}
