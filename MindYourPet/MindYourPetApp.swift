//
//  MindYourPetApp.swift
//  MindYourPet
//
//  Created by Irene Serrano on 8/20/25.
//

import SwiftUI
import Firebase

@main
struct MindYourPetApp: App {
    @UIApplicationDelegateAdaptor(AppApplicationDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppApplicationDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
