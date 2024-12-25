//
//  SharedBtEventManager.swift
//  BLEcommunicator
//
//  Created by Mate Granic on 25.12.2024..
//

import Foundation

class SharedBtEventManager: ObservableObject {
    @Published var events: [BtEvent] = []
    
    func createEvent(name: String) {
        events.append(BtEvent(name: name))
       }
}
