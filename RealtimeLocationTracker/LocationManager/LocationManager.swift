//
//  LocationManager.swift
//  RealtimeLocationTracker
//
//  Created by Rajat Verma on 20/07/25.
//

import Foundation
import CoreLocation
import SwiftUI
import FirebaseFirestore

// This class manages locations for the app user
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    private let db = Firestore.firestore()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
          self.location = location
        
        // Replace with actual user ID from Auth or static
        let userId = UIDevice.current.identifierForVendor?.uuidString ?? "test-user"
        uploadLocation(userId: userId, coordinate: location.coordinate) { result in
            switch result {
            case .success():
                print("✅ Location uploaded successfully.")
            case .failure(let error):
                print("❌ Upload failed: \(error.localizedDescription)")
            }
        }
    }
    
    // this function is used to update data to firestore
    func uploadLocation(userId: String, coordinate: CLLocationCoordinate2D, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("locations").document(userId).setData([
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "timestamp": Date().timeIntervalSince1970
        ], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
}
