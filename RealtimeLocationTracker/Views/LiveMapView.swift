//
//  LiveMapView.swift
//  RealtimeLocationTracker
//
//  Created by Rajat Verma on 21/07/25.
//

import SwiftUI
import MapKit
import FirebaseFirestore

// This view is showing map on the screen with users locations pins
struct LiveMapView: View {
    @ObservedObject private var locationFetcher = LocationFetcher()
    let currentDeviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
    @State private var myLocation: CLLocationCoordinate2D?
    @State private var shouldFollowUser = true
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(center: .init(), span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)))
    @State private var selectedUserRoute: [CLLocationCoordinate2D] = []
    @State private var selectedUserId: String? = nil

    var body: some View {
        let locations = locationFetcher.allUserLocations
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition, interactionModes: .all) {
                    ForEach(locations) { user in
                        let isCurrentUser = (user.id == currentDeviceId)
                        Marker(isCurrentUser ? "You" : user.id.prefix(4), image: isCurrentUser ? "mappin.circle.fill" : "mappin", coordinate: user.coordinate)
                            .tint(isCurrentUser ? .blue : .red)
                    }

                    if let _ = selectedUserId, !selectedUserRoute.isEmpty {
                        MapPolyline(coordinates: selectedUserRoute ?? [])
                            .stroke(.green, lineWidth: 4)
                    }
                }
                .mapStyle(.standard)
                .onReceive(locationFetcher.$allUserLocations) { locations in
                    if let me = locations.first(where: { $0.id == currentDeviceId }) {
                        myLocation = me.coordinate
                        guard let myLoc = myLocation else { return }
                        if case let region = cameraPosition.region {
                            let camCenter = region?.center
                            let dist = CLLocation(latitude: myLoc.latitude, longitude: myLoc.longitude)
                                .distance(from: CLLocation(latitude: camCenter?.latitude ?? 0.0, longitude: camCenter?.longitude ?? 0.0))

                            if dist > 50 {
                                shouldFollowUser = false
                            }
                        }

                        if shouldFollowUser {
                            cameraPosition = .region(MKCoordinateRegion(
                                center: myLoc,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            ))
                        }
                    }
                }

                Button {
                    shouldFollowUser = true
                    if let myLoc = myLocation {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: myLoc,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))
                    }
                } label: {
                    Image(systemName: "location.fill")
                        .padding()
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 3)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(locations.filter { $0.id != currentDeviceId }, id: \.id) { user in
                            Button(user.id.prefix(6)) {
                                selectedUserId = user.id
                                loadUserRoute(userId: user.id)
                            }
                        }
                    } label: {
                        Label("Users", systemImage: "person.3.fill")
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let current = locationFetcher.allUserLocations.first(where: { $0.id == currentDeviceId }) {
                        myLocation = current.coordinate
                        cameraPosition = .region(MKCoordinateRegion(
                            center: current.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))
                    } else {
                        print("⚠️ User with ID \(currentDeviceId) not found.")
                    }
                }
            }
        }
    }
    
    func loadUserRoute(userId: String) {
        Firestore.firestore().collection("locations").document(userId).getDocument { document, error in
            if let error = error {
                print("❌ Error fetching document: \(error)")
                return
            }

            guard let data = document?.data(),
                  let lat = data["latitude"] as? Double,
                  let lon = data["longitude"] as? Double else {
                print("❌ Invalid document format or data missing.")
                return
            }

            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

            DispatchQueue.main.async {
                if let myLocation = self.myLocation {
                    self.selectedUserRoute = [myLocation, coordinate]
                } else {
                    print("❌ My location not yet available.")
                    return
                }
            }
        }
    }




}

#Preview {
    LiveMapView()
}

