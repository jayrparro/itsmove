//
//  BookingLocation.swift
//  MySmove
//
//  Created by Leonardo Parro on 10/7/18.
//  Copyright © 2018 Leonardo Parro. All rights reserved.
//

import Foundation
import CoreLocation

struct BookingList: Codable {
    let bookings: [Booking]
    
    enum CodingKeys: String, CodingKey {
        case bookings = "data"
    }
}

struct Booking: Codable {
    let id: Int
    let location: [Double]
    let availableCars: Int
    let dropoffLocations: [DropOffLocation]
    
    enum CodingKeys: String, CodingKey {
        case id
        case location
        case availableCars = "available_cars"
        case dropoffLocations = "dropoff_locations"
    }
    
    func getLocationAddress(location: CLLocation, handler: @escaping (String) -> Void) {
        performReverseGeocode(location: location) { result in
            handler(result)
        }
    }
    
    func getStartLocationAddress(handler: @escaping (String) -> Void) {
        if location.count > 0 {
            let loc = CLLocation(latitude: location[0], longitude: location[1])
            performReverseGeocode(location: loc) { result in
                handler(result)
            }
        }
    }
    
    func getDropOffLocationAddress(handler: @escaping ([String]) -> Void){
        debugPrint("dropoffLocations --- count: \(dropoffLocations.count)")
        if dropoffLocations.count > 0 {
            var addresses = [String]()
            
            dropoffLocations.forEach { dropOffLocation in
                let loc = CLLocation(latitude: dropOffLocation.location[0], longitude: dropOffLocation.location[1])
                performReverseGeocode(location: loc, handler: { result in
                    addresses.append(result)
                })
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                handler(addresses)
            }
        }
    }
    
    fileprivate func performReverseGeocode(location: CLLocation, handler: @escaping (String) -> Void) {
        var address = ""
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                debugPrint("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks else {
                return
            }
            
            if placemarks.count > 0 {
                let countryCode = placemarks[0].isoCountryCode!
                let city = placemarks[0].locality ?? ""
                let name = placemarks[0].name ?? ""
                let zip = placemarks[0].postalCode ?? ""
                
                //debugPrint("name: \(name), city: \(city), country: \(countryCode), zip: \(zip)")
                address = "\(name), \(city), \(countryCode), \(zip)"
                
                handler(address)
                
            } else {
                debugPrint("Problem with the data received from geocoder")
                return
            }
        })
    }
}

struct DropOffLocation: Codable {    
    let id: Int
    let location: [Double]
}
