//

import Foundation
import CallKit
import AVFAudio

//  Untitled.swift
//  CarPlayVOIPDemo
//
//  Created by Arunesh Rathore on 15/07/25.
//

class CallManager: NSObject, ObservableObject {
    static let shared = CallManager()
    
    private let callController = CXCallController()
    private let provider: CXProvider
    @Published var activeCall: Call?
    @Published var callHistory: [Call] = []
    
    private var callTimer: Timer?
    
    override init() {
        let configuration = CXProviderConfiguration(localizedName: "VOIP Demo")
        configuration.supportsVideo = false
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportedHandleTypes = [.phoneNumber]
        configuration.includesCallsInRecents = true
        
        // CarPlay optimizations
        configuration.ringtoneSound = "ringtone.caf"
        
        provider = CXProvider(configuration: configuration)
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
    
    func startOutgoingCall(to contact: Contact) {
        let callUUID = UUID()
        let handle = CXHandle(type: .phoneNumber, value: contact.phoneNumber)
        let startCallAction = CXStartCallAction(call: callUUID, handle: handle)
        
        startCallAction.isVideo = false
        startCallAction.contactIdentifier = contact.name
        
        let transaction = CXTransaction(action: startCallAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Error starting call: \(error)")
            } else {
                DispatchQueue.main.async {
                    let call = Call(uuid: callUUID, handle: handle.value, contact: contact)
                    self?.activeCall = call
                    self?.startCallTimer()
                    CarPlayManager.shared.presentCallTemplate(for: call)
                }
            }
        }
    }
    
    func endCall() {
        guard let call = activeCall else { return }
        
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Error ending call: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.stopCallTimer()
                    call.callState = .ended
                    self?.callHistory.append(call)
                    self?.activeCall = nil
                }
            }
        }
    }
    
    func muteCall() {
        guard let call = activeCall else { return }
        
        let muteAction = CXSetMutedCallAction(call: call.uuid, muted: !call.isMuted)
        let transaction = CXTransaction(action: muteAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Error muting call: \(error)")
            } else {
                DispatchQueue.main.async {
                    call.isMuted.toggle()
                }
            }
        }
    }
    
    func holdCall() {
        guard let call = activeCall else { return }
        
        let holdAction = CXSetHeldCallAction(call: call.uuid, onHold: !call.isOnHold)
        let transaction = CXTransaction(action: holdAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Error holding call: \(error)")
            } else {
                DispatchQueue.main.async {
                    call.isOnHold.toggle()
                    call.callState = call.isOnHold ? .onHold : .connected
                    CarPlayManager.shared.updateCallTemplate(for: call)
                }
            }
        }
    }
    
    private func startCallTimer() {
        callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let call = self?.activeCall else { return }
            DispatchQueue.main.async {
                call.duration += 1
                if call.callState == .connected {
                    CarPlayManager.shared.updateCallTemplate(for: call)
                }
            }
        }
    }
    
    private func stopCallTimer() {
        callTimer?.invalidate()
        callTimer = nil
    }
    
    func simulateIncomingCall() {
        let contact = CarPlayManager.shared.contacts.randomElement()!
        let callUUID = UUID()
        let handle = CXHandle(type: .phoneNumber, value: contact.phoneNumber)
        
        let update = CXCallUpdate()
        update.remoteHandle = handle
        update.localizedCallerName = contact.name
        update.hasVideo = false
        
        provider.reportNewIncomingCall(with: callUUID, update: update) { error in
            if let error = error {
                print("Error reporting incoming call: \(error)")
            } else {
                DispatchQueue.main.async {
                    let call = Call(uuid: callUUID, handle: handle.value, contact: contact)
                    call.isOutgoing = false
                    self.activeCall = call
                }
            }
        }
    }
}

// MARK: - CXProviderDelegate
extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // Reset all calls
        DispatchQueue.main.async {
            self.activeCall = nil
            self.stopCallTimer()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Configure audio session
        configureAudioSession()
        
        // Report call as connecting
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
        
        // Simulate connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
            self.activeCall?.callState = .connected
            self.activeCall?.isConnected = true
            if let call = self.activeCall {
                CarPlayManager.shared.updateCallTemplate(for: call)
            }
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        configureAudioSession()
        
        DispatchQueue.main.async {
            self.activeCall?.callState = .connected
            self.activeCall?.isConnected = true
            self.startCallTimer()
            if let call = self.activeCall {
                CarPlayManager.shared.presentCallTemplate(for: call)
            }
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        DispatchQueue.main.async {
            self.stopCallTimer()
            self.activeCall?.callState = .ended
            if let call = self.activeCall {
                self.callHistory.append(call)
            }
            self.activeCall = nil
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        DispatchQueue.main.async {
            self.activeCall?.isMuted = action.isMuted
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        DispatchQueue.main.async {
            self.activeCall?.isOnHold = action.isOnHold
            self.activeCall?.callState = action.isOnHold ? .onHold : .connected
            if let call = self.activeCall {
                CarPlayManager.shared.updateCallTemplate(for: call)
            }
        }
        action.fulfill()
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Error configuring audio session: \(error)")
        }
    }
}
