//
//  SharedAlertManager.swift
//  BLEcommunicator
//
//  Created by Mate Granic on 10.12.2024..
//

import Foundation

struct AlertData {
    var title: String
    var message: String
}

class SharedAlertManager: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var alertData: AlertData = AlertData(title: "", message: "")
    
    func triggerAlert(title: String, message: String) {
           alertData = AlertData(title: title, message: message)
           showAlert = true
       }
}

