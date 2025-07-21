//
//  RealtimeLocationTrackerApp.swift
//  RealtimeLocationTracker
//
//  Created by Rajat Verma on 20/07/25.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAppCheck

class MyDebugAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppCheckDebugProvider(app: app)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      AppCheck.setAppCheckProviderFactory(MyDebugAppCheckProviderFactory())
      FirebaseApp.configure()
      

    return true
  }
}

@main
struct RealtimeLocationTrackerApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
