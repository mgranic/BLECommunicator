//
//  SettingsScreen.swift
//  BLEcommunicator
//
//  Created by Mate Granic on 23.12.2024..
//

import SwiftUI

struct SettingsScreen: View {
    let operations = ["Read", "Write"]  // Available operations
    let period = [1000, 2000, 3000, 4000, 5000]  // Available periods
    @State private var selectedOperation = "Write"  // message
    @State private var selectedPeriodicOperation = "Read"  // periodic message
    @State private var selectedPeriod = 1000  // period
    @State private var isServer: Bool = true // Default state (true for "Server")
    
    
    var body: some View {
        VStack {
            HStack {
                Toggle(isOn: $isServer) {
                    Text("Mode: \(isServer ? "Server" : "Client")")
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue)) // Customize the toggle appearance
                .padding()
            }
            HStack {
                Text("Message on tap")
                // New Picker for operations
                Picker("Operation", selection: $selectedOperation) {
                    ForEach(operations, id: \.self) { operation in
                        Text(operation)
                    }
                }
            }
            HStack {
                Text("Periodic message")
                // New Picker for operations
                Picker("Periodic operation", selection: $selectedPeriodicOperation) {
                    ForEach(operations, id: \.self) { operation in
                        Text(operation)
                    }
                }
            }
            HStack {
                Text("Message period")
                // New Picker for operations
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(period, id: \.self) { period in
                        Text(String(period))
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsScreen()
}
