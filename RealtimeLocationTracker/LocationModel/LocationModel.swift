//
//  LocationModel.swift
//  RealtimeLocationTracker
//
//  Created by Rajat Verma on 21/07/25.
//
import Foundation
import CoreLocation

// Model for the Location Data for the User
struct FirestoreLocation: Identifiable, Equatable  {
    let id: String
    let latitude: Double
    let longitude: Double
    let timestamp: TimeInterval

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Add Equatable manually because CLLocationCoordinate2D is not Equatable by default
      static func == (lhs: FirestoreLocation, rhs: FirestoreLocation) -> Bool {
          return lhs.id == rhs.id &&
                 lhs.coordinate.latitude == rhs.coordinate.latitude &&
                 lhs.coordinate.longitude == rhs.coordinate.longitude
      }
}

