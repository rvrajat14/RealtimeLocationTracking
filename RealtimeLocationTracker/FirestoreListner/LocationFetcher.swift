//
//  FirestoreListner.swift
//  RealtimeLocationTracker
//
//  Created by Rajat Verma on 21/07/25.
//

import Foundation
import FirebaseFirestore
import CoreLocation

// this class is used to fetch all the users locations from firebase
class LocationFetcher: ObservableObject {
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    @Published var allUserLocations: [FirestoreLocation] = []

    init() {
        listenToLocationUpdates()
    }

    func listenToLocationUpdates() {
        listener = db.collection("locations").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("❌ Error fetching snapshots: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.allUserLocations = documents.compactMap { doc in
                let data = doc.data()
                guard let lat = data["latitude"] as? Double,
                      let lon = data["longitude"] as? Double,
                      let timestamp = data["timestamp"] as? TimeInterval else { return nil }

                return FirestoreLocation(id: doc.documentID, latitude: lat, longitude: lon, timestamp: timestamp)
            }
        }
    }

    deinit {
        listener?.remove()
    }
}
