//
//  SettingsScreen.swift
//  BLEcommunicator
//
//  Created by Mate Granic on 23.12.2024..
//

import SwiftUI

struct SettingsScreen: View {
    //let operations = ["Read", "Write"]  // Available operations
    @State private var selectedPeriod: MessagePeriod = .sec_1  // Changed type to MessagePeriod
    @State private var selectedOperation = OperationType.write  // message
    @State private var selectedPeriodicOperation = OperationType.read  // periodic message
    //@State private var selectedPeriod = 1000  // period
    
    private var settingsManager = SettingManager()
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Message on tap")
                // New Picker for operations
                Picker("Operation", selection: $selectedOperation) {
                    ForEach(OperationType.allCases, id: \.self) { operation in
                        Text(operation.rawValue)
                    }
                }
                .onChange(of: selectedOperation) {
                    settingsManager.setOperationType(operation: selectedOperation)
                }
            }
            HStack {
                Text("Periodic message")
                // New Picker for operations
                Picker("Periodic operation", selection: $selectedPeriodicOperation) {
                    ForEach(OperationType.allCases, id: \.self) { operation in
                        Text(operation.rawValue)
                    }
                }
                .onChange(of: selectedPeriodicOperation) {
                    settingsManager.setPeriodicOperationType(operation: selectedPeriodicOperation)
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
                    settingsManager.setDefaultPeriod(period: selectedPeriod)
                }
            }
            .onAppear {
                selectedPeriod = settingsManager.getDefaultPeriod()
                selectedPeriodicOperation = settingsManager.getPeriodicOperationType()
                selectedOperation = settingsManager.getOperationType()
            }
        }
    }
}

#Preview {
    SettingsScreen()
}
