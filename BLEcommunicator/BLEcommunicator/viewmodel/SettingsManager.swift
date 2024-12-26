//
//  SettingsManager.swift
//  BLEcommunicator
//
//  Created by Mate Granic on 26.12.2024..
//

import Foundation

struct SettingManager {
    
    // save default bt_message_period to user defaults
    func setDefaultPeriod(period: MessagePeriod) {
        UserDefaults.standard.setValue(period.rawValue, forKey: "bt_message_period")
    }
    
    // read bt_message_period from user defaults
    func getDefaultPeriod() -> MessagePeriod {
        let defaultPeriod =  MessagePeriod(rawValue: (UserDefaults.standard.integer(forKey: "bt_message_period")))
        
        return defaultPeriod ?? MessagePeriod.sec_1
    }
}
