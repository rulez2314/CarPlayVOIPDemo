//
//  AppDelegate.swift
//  CarPlayVOIPDemo
//
//  Created by Arunesh Rathore on 15/07/25.
//

import SwiftUI
import CarPlay
import CallKit
import AVFoundation
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        if connectingSceneSession.role == UISceneSession.Role.carTemplateApplication {
            let config = UISceneConfiguration(name: "CarPlay", sessionRole: connectingSceneSession.role)
            config.delegateClass = CarPlaySceneDelegate.self
            return config
        } else {
            let config = UISceneConfiguration(name: "Phone", sessionRole: connectingSceneSession.role)
            config.delegateClass = PhoneSceneDelegate.self
            return config
        }
    }
}

