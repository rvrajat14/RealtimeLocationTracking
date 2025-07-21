//
//  LiveMapView.swift
//  RealtimeLocationTracker
//
//  Created by Rajat Verma on 21/07/25.
//

import SwiftUI
import MapKit

// This view is showing map on the screen with users locations pins
struct LiveMapView: View {
    @StateObject private var locationFetcher = LocationFetcher()
    let currentDeviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
    @State private var myLocation: CLLocationCoordinate2D?
    @State private var shouldFollowUser = true
    
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(center: .init(), span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)))

    
    var body: some View {
        let locations = locationFetcher.allUserLocations
        return ZStack {
            Map(position: $cameraPosition, interactionModes: .all) {
                ForEach(locations) { user in
                    let isCurrentUser = (user.id == currentDeviceId)
                    Marker(isCurrentUser ? "You" : user.id.prefix(4), image: isCurrentUser ? "mappin.circle.fill" : "mappin", coordinate: user.coordinate)
                        .tint(isCurrentUser ? .blue : .red)
                    
                }
            }
            
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
        
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let current = locationFetcher.allUserLocations.first(where: { $0.id == currentDeviceId }) {
                    myLocation = current.coordinate
                    cameraPosition = .region(MKCoordinateRegion(
                        center: current.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                }
            }
         
        }

        
    }

}

#Preview {
    LiveMapView()
}

