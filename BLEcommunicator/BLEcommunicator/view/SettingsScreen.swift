//
//  SettingsScreen.swift
//  BLEcommunicator
//
//  Created by Mate Granic on 23.12.2024..
//

import SwiftUI

struct SettingsScreen: View {
    let operations = ["Read", "Write"]  // Available operations
    @State private var selectedPeriod: MessagePeriod = .sec_1  // Changed type to MessagePeriod
    @State private var selectedOperation = "Write"  // message
    @State private var selectedPeriodicOperation = "Read"  // periodic message
    //@State private var selectedPeriod = 1000  // period
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
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(MessagePeriod.allCases, id: \.self) { period in
                        Text("\(period.rawValue) ms")
                    }
                }
                .onChange(of: selectedPeriod) {
                    print("Selected period: \(selectedPeriod)")
                    SettingManager().setDefaultPeriod(period: selectedPeriod)
                }
            }
            .onAppear {
                selectedPeriod = SettingManager().getDefaultPeriod()
            }
        }
    }
}

#Preview {
    SettingsScreen()
}
