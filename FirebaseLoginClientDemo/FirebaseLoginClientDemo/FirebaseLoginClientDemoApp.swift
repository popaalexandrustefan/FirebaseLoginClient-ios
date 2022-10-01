//
//  FirebaseLoginClientDemoApp.swift
//  FirebaseLoginClientDemo
//
//  Created by Alexandru Popa on 01.10.2022.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct FirebaseLoginClientDemoApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  var body: some Scene {
    WindowGroup {
      ContentView(viewModel: .init())
    }
  }
}
