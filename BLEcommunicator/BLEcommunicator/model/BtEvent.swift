//
//  BtEvent.swift
//  BLEcommunicator
//
//  Created by Mate Granic on 25.12.2024..
//

import Foundation

struct BtEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let name: String
    
    init(name: String) {
        self.timestamp = Date()
        self.name = name
    }
}
