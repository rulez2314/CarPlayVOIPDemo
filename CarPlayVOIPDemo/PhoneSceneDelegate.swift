//
//  Untitled.swift
//  CarPlayVOIPDemo
//
//  Created by Arunesh Rathore on 15/07/25.
//
import SwiftUI
import CarPlay
import CallKit
import AVFoundation
import Combine

class PhoneSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let contentView = ContentView()
            .environment(\.carPlayManager, CarPlayManager.shared)
            .environment(\.callManager, CallManager.shared)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
    }
}
