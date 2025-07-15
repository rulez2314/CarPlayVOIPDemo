//
//  ContentView.swift
//  CarPlayVOIPDemo
//
//  Created by Arunesh Rathore on 15/07/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.callManager) private var callManager
    @Environment(\.carPlayManager) private var carPlayManager
    
    var body: some View {
        NavigationView {
            VStack {
                if let activeCall = callManager.activeCall {
                    CallView(call: activeCall)
                } else {
                    ContactsView()
                }
            }
            .navigationTitle("VOIP Demo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simulate Incoming") {
                        callManager.simulateIncomingCall()
                    }
                }
            }
        }
    }
}

// MARK: - Contacts View
struct ContactsView: View {
    @Environment(\.carPlayManager) private var carPlayManager
    @Environment(\.callManager) private var callManager
    
    var body: some View {
        List(carPlayManager.contacts) { contact in
            ContactRow(contact: contact) {
                callManager.startOutgoingCall(to: contact)
            }
        }
    }
}

// MARK: - Contact Row
struct ContactRow: View {
    let contact: Contact
    let onCall: () -> Void
    
    var body: some View {
        HStack {
            Text(contact.avatar)
                .font(.system(size: 40))
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.headline)
                Text(contact.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onCall) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Call View
struct CallView: View {
    @ObservedObject var call: Call
    @Environment(\.callManager) private var callManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Contact Info
            VStack(spacing: 16) {
                Text(call.contact.avatar)
                    .font(.system(size: 120))
                    .frame(width: 200, height: 200)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text(call.contact.name)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                
                Text(call.callState == .connected ? formatDuration(call.duration) : call.contact.phoneNumber)
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(statusText)
                    .font(.headline)
                    .foregroundColor(statusColor)
            }
            
            Spacer()
            
            // Call Controls
            HStack(spacing: 60) {
                CallControlButton(
                    icon: call.isMuted ? "mic.slash.fill" : "mic.fill",
                    color: call.isMuted ? .red : .gray,
                    action: { callManager.muteCall() }
                )
                
                CallControlButton(
                    icon: "phone.down.fill",
                    color: .red,
                    action: { callManager.endCall() }
                )
                
                CallControlButton(
                    icon: call.isOnHold ? "pause.fill" : "play.fill",
                    color: call.isOnHold ? .orange : .gray,
                    action: { callManager.holdCall() }
                )
            }
            .padding(.bottom, 50)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var statusText: String {
        switch call.callState {
        case .connecting:
            return call.isOutgoing ? "Calling..." : "Incoming call"
        case .connected:
            return call.isOnHold ? "On Hold" : "Connected"
        case .onHold:
            return "On Hold"
        case .ended:
            return "Call Ended"
        }
    }
    
    private var statusColor: Color {
        switch call.callState {
        case .connecting:
            return .blue
        case .connected:
            return .green
        case .onHold:
            return .orange
        case .ended:
            return .red
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Call Control Button
struct CallControlButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .clipShape(Circle())
        }
    }
}
