//
//  Untitled.swift
//  CarPlayVOIPDemo
//
//  Created by Arunesh Rathore on 15/07/25.
//

import Foundation
import CarPlay
import SwiftUICore



struct CarPlayManagerKey: EnvironmentKey {
    static let defaultValue = CarPlayManager.shared
}

struct CallManagerKey: EnvironmentKey {
    static let defaultValue = CallManager.shared
}

extension EnvironmentValues {
    var carPlayManager: CarPlayManager {
        get { self[CarPlayManagerKey.self] }
        set { self[CarPlayManagerKey.self] = newValue }
    }
    
    var callManager: CallManager {
        get { self[CallManagerKey.self] }
        set { self[CallManagerKey.self] = newValue }
    }
}

// MARK: - Models
struct Contact: Identifiable, Codable {
    var id = UUID()
    let name: String
    let phoneNumber: String
    let avatar: String
    
    init(name: String, phoneNumber: String, avatar: String = "") {
        self.name = name
        self.phoneNumber = phoneNumber
        self.avatar = avatar
    }
}

class Call: ObservableObject, Identifiable {
    let id = UUID()
    let uuid: UUID
    let handle: String
    let contact: Contact
    @Published var isConnected = false
    @Published var isMuted = false
    @Published var isOnHold = false
    @Published var isOutgoing = true
    @Published var duration: TimeInterval = 0
    @Published var callState: CallState = .connecting
    
    init(uuid: UUID, handle: String, contact: Contact) {
        self.uuid = uuid
        self.handle = handle
        self.contact = contact
    }
}

enum CallState {
    case connecting
    case connected
    case onHold
    case ended
}

// MARK: - CarPlay Manager
class CarPlayManager: ObservableObject {
    static let shared = CarPlayManager()
    
    private var interfaceController: CPInterfaceController?
    private var callTemplate: CPVoiceControlTemplate?
    
    let contacts = [
        Contact(name: "John Doe", phoneNumber: "+1 (555) 123-4567", avatar: "👨‍💼"),
        Contact(name: "Jane Smith", phoneNumber: "+1 (555) 987-6543", avatar: "👩‍💻"),
        Contact(name: "Bob Johnson", phoneNumber: "+1 (555) 456-7890", avatar: "👨‍🔧"),
        Contact(name: "Alice Brown", phoneNumber: "+1 (555) 321-0987", avatar: "👩‍🎨"),
        Contact(name: "Mike Wilson", phoneNumber: "+1 (555) 654-3210", avatar: "👨‍🎓"),
        Contact(name: "Sarah Davis", phoneNumber: "+1 (555) 789-0123", avatar: "👩‍⚕️"),
        Contact(name: "Tom Miller", phoneNumber: "+1 (555) 234-5678", avatar: "👨‍🍳"),
        Contact(name: "Emma Garcia", phoneNumber: "+1 (555) 567-8901", avatar: "👩‍🚀")
    ]
    
    func setInterfaceController(_ controller: CPInterfaceController?) {
        self.interfaceController = controller
    }
    
    func createMainTemplate() -> CPTabBarTemplate {
        let contactsTemplate = createContactsTemplate()
        let recentsTemplate = createRecentsTemplate()
        let favoritesTemplate = createFavoritesTemplate()
        
        let tabBarTemplate = CPTabBarTemplate(templates: [
            contactsTemplate,
            recentsTemplate,
            favoritesTemplate
        ])
        
        return tabBarTemplate
    }
    
    private func createContactsTemplate() -> CPListTemplate {
        let contactItems = contacts.map { contact in
            let item = CPListItem(text: contact.name, detailText: contact.phoneNumber)
            item.handler = { [weak self] _, completion in
                self?.initiateCall(to: contact)
                completion()
            }
            return item
        }
        
        let section = CPListSection(items: contactItems)
        let template = CPListTemplate(title: "Contacts", sections: [section])
        template.tabTitle = "Contacts"
        template.tabImage = UIImage(systemName: "person.2.fill")
        
        return template
    }
    
    private func createRecentsTemplate() -> CPListTemplate {
        let recentItems = contacts.prefix(3).map { contact in
            let item = CPListItem(text: contact.name, detailText: "Recent • \(contact.phoneNumber)")
            item.handler = { [weak self] _, completion in
                self?.initiateCall(to: contact)
                completion()
            }
            return item
        }
        
        let section = CPListSection(items: Array(recentItems))
        let template = CPListTemplate(title: "Recents", sections: [section])
        template.tabTitle = "Recents"
        template.tabImage = UIImage(systemName: "clock.fill")
        
        return template
    }
    
    private func createFavoritesTemplate() -> CPListTemplate {
        let favoriteItems = contacts.prefix(2).map { contact in
            let item = CPListItem(text: contact.name, detailText: "⭐ \(contact.phoneNumber)")
            item.handler = { [weak self] _, completion in
                self?.initiateCall(to: contact)
                completion()
            }
            return item
        }
        
        let section = CPListSection(items: Array(favoriteItems))
        let template = CPListTemplate(title: "Favorites", sections: [section])
        template.tabTitle = "Favorites"
        template.tabImage = UIImage(systemName: "star.fill")
        
        return template
    }
    
    private func initiateCall(to contact: Contact) {
        CallManager.shared.startOutgoingCall(to: contact)
    }
    
    func presentCallTemplate(for call: Call) {
        guard let interfaceController = interfaceController else { return }

        if let currentTemplate = interfaceController.templates.last {
            interfaceController.popTemplate(animated: true, completion: {_,_ in 
                let callTemplate = self.createCallTemplate(for: call)
                interfaceController.presentTemplate(callTemplate, animated: true, completion: nil)
            })
        } else {
            let callTemplate = createCallTemplate(for: call)
            interfaceController.presentTemplate(callTemplate, animated: true, completion: nil)
        }
    }

    
    private func createCallTemplate(for call: Call) -> CPVoiceControlTemplate {
        let voiceControlStates = [
            CPVoiceControlState(
                identifier: "calling",
                titleVariants: ["Calling \(call.contact.name)"],
                image: UIImage(systemName: "phone.fill"), repeats: true
            )
        ]
        
        let template = CPVoiceControlTemplate(voiceControlStates: voiceControlStates)
        template.activateVoiceControlState(withIdentifier: "calling")
        
        self.callTemplate = template
        return template
    }
    
    func updateCallTemplate(for call: Call) {
        guard let template = callTemplate else { return }
        
        let stateId = call.callState == .connected ? "connected" : "calling"
        let title = call.callState == .connected ? "Connected to \(call.contact.name)" : "Calling \(call.contact.name)"
        let subtitle = call.callState == .connected ? formatDuration(call.duration) : call.contact.phoneNumber
        
        let state = CPVoiceControlState(
            identifier: stateId,
            titleVariants: [title],
            image: UIImage(systemName: call.callState == .connected ? "phone.fill" : "phone.arrow.up.right"), repeats: true
        )
        
        template.activateVoiceControlState(withIdentifier: stateId)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

