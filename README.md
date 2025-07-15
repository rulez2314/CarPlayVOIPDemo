# 🚘📞 CarPlay VOIP Demo App

This is a Swift-based iOS application demonstrating integration with **Apple CarPlay** and **CallKit** to create a custom VOIP calling experience.  
It showcases a modern architecture using SwiftUI, UIKit scene delegates, CarPlay templates, and real-time call state management.

---

## ✨ Features

- ✅ **Apple CarPlay support** using `CPTemplateApplicationSceneDelegate`
- ✅ Custom VOIP call management via **CallKit** (`CXProvider`, `CXCallController`)
- ✅ Interactive CarPlay UI with Contacts, Recents, and Favorites tabs
- ✅ Voice control template presentation on CarPlay during calls
- ✅ SwiftUI-based phone app UI with outgoing and simulated incoming calls
- ✅ Mute, hold, and end call functionalities
- ✅ Seamless integration between SwiftUI and UIKit (scene delegates)
- ✅ Clean separation of CarPlay and phone scene logic

---

## 📂 Project Structure

- **CarPlayVOIPApp.swift**: Main app entry point using `@main` and `UIApplicationDelegateAdaptor`.
- **AppDelegate**: Handles scene configuration and decides which scene delegate to use.
- **PhoneSceneDelegate**: Controls the SwiftUI-based phone UI scene.
- **CarPlaySceneDelegate**: Manages CarPlay connection, UI templates, and navigation.
- **CarPlayManager**: Central class to build CarPlay UI templates and handle CarPlay logic.
- **CallManager**: Manages VOIP calls using CallKit, including state updates and actions.
- **Info.plist**: Configured with `UISupportsCarPlay`, scene manifest, and background modes.

---

## ⚙️ Technical Highlights

### CarPlay Integration

- Uses `CPTabBarTemplate`, `CPListTemplate`, and `CPVoiceControlTemplate` for dynamic UI.
- Presents different tabs: Contacts, Recents, and Favorites.
- Supports real-time call updates in CarPlay interface.

### CallKit Integration

- Handles outgoing and incoming VOIP calls using `CXProvider` and `CXCallController`.
- Integrates mute, hold, and end call actions.
- Updates CarPlay and phone UIs simultaneously.

### SwiftUI & UIKit Scene Delegates

- Scene-based architecture separating CarPlay and phone experiences.
- SwiftUI views injected using `UIHostingController`.
- Environment objects (`CarPlayManager`, `CallManager`) shared across scenes.

---

## 🚀 Running the App

### Requirements

- Xcode 15 or later
- iOS 16.x or later simulator (iPhone only)
- Swift 5.7+

### Steps

1️⃣ Open the project in Xcode.  
2️⃣ Select an **iPhone simulator** .  
3️⃣ Build and run the app.  
4️⃣ In Simulator menu, enable CarPlay display: I/O > External Displays > CarPlay

