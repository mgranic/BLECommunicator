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
    
    // save periodic operation type
    func setPeriodicOperationType(operation: OperationType) {
        UserDefaults.standard.setValue(operation.rawValue, forKey: "periodic_operation_type")
    }
    
    // read periodic_operation_type from user defaults
    func getPeriodicOperationType() -> OperationType {
        let operationType =  OperationType(rawValue: (UserDefaults.standard.string(forKey: "periodic_operation_type") ?? OperationType.read.rawValue))
        
        return operationType ?? OperationType.read
    }

    // save operation type
    func setOperationType(operation: OperationType) {
        UserDefaults.standard.setValue(operation.rawValue, forKey: "operation_type")
    }

    // read operation type from user defaults
    func getOperationType() -> OperationType {
        let operationType =  OperationType(rawValue: (UserDefaults.standard.string(forKey: "operation_type") ?? OperationType.write.rawValue))
        
        return operationType ?? OperationType.write
    }
}
