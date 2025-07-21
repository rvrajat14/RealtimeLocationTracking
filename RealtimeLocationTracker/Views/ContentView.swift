//
//  ContentView.swift
//  RealtimeLocationTracker
//
//  Created by Rajat Verma on 20/07/25.
//

import SwiftUI
import MapKit


struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    var body: some View {
        VStack {
            LiveMapView()
        }
    }
}

#Preview {
    ContentView()
}
