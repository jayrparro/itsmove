//
//  Fetcher.swift
//  MySmove
//
//  Created by Leonardo Parro on 9/7/18.
//  Copyright © 2018 Leonardo Parro. All rights reserved.
//

import Foundation

class Fetcher {
    static let sharedInstance = Fetcher()
    
    fileprivate let HOST_API_URL = "challenge.smove.sg"
    fileprivate let HTTP_SCHEME = "https"
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    enum APIEndpoint: String {
        case Locations = "/locations"
        case BookingAvailability = "/availability"
    }
    
    let defaultSession = URLSession(configuration: .default)
    
    
    // MARK: - GET Car Locations
    func getAllCarLocations(completion: ((Result<[CarLocation]>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = HTTP_SCHEME
        urlComponents.host = HOST_API_URL
        urlComponents.path = APIEndpoint.Locations.rawValue
        
        guard let url = urlComponents.url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = defaultSession.dataTask(with: request) { responseData, response, responseError in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                    
                } else if let jsonData = responseData,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    let decoder = JSONDecoder()
                    do {
                        #if DEBUG
                        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                        debugPrint(jsonObject)
                        #endif
                        
                        let locationList = try decoder.decode(CarLocationList.self, from: jsonData)
                        completion?(.success(locationList.locations))
                        
                    } catch {
                        completion?(.failure(error))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - GET Booking Availability
    func getBookingAvailability(startTime: TimeInterval, endTime: TimeInterval, completion: ((Result<[Booking]>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = HTTP_SCHEME
        urlComponents.host = HOST_API_URL
        urlComponents.path = APIEndpoint.BookingAvailability.rawValue        
        
        let startTimeItem = URLQueryItem(name: "startTime", value: "\(String(format: "%.f", Double(startTime)))")
        let endTimeItem = URLQueryItem(name: "endTime", value: "\(String(format: "%.f", Double(endTime)))")
        urlComponents.queryItems = [startTimeItem, endTimeItem]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = defaultSession.dataTask(with: request) { responseData, response, responseError in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                    
                } else if let jsonData = responseData,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    let decoder = JSONDecoder()
                    do {
                        #if DEBUG
                        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                        debugPrint(jsonObject)
                        #endif
                        
                        let bookingList = try decoder.decode(BookingList.self, from: jsonData)
                        completion?(.success(bookingList.bookings))
                        
                    } catch {
                        completion?(.failure(error))
                    }
                }
            }
        }
        
        task.resume()
    }
}
