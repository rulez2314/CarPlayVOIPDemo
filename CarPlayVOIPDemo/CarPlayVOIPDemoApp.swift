import SwiftUI
import CarPlay
import CallKit
import AVFoundation
import Combine

// MARK: - App Entry Point
@main
struct CarPlayVOIPApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(\.carPlayManager, CarPlayManager.shared)
        .environment(\.callManager, CallManager.shared)
    }
}
