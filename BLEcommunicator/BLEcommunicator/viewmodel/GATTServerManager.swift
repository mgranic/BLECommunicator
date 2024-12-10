import CoreBluetooth
import SwiftUI

class GATTServerManager: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager?
    private var customServiceUUID = CBUUID(string: "12345678-1234-5678-1234-567812345678")
    private var customCharacteristicUUID = CBUUID(string: "a7e550c4-69d1-4a6b-9fe7-8e21e5d571b6")
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var isAdvertising = false

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Peripheral Manager State
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheralManagerDidUpdateState")
        switch peripheral.state {
        case .poweredOn:
            print("Peripheral Manager is powered on.")
            setupGATTServer()
        case .poweredOff:
            print("Bluetooth is powered off.")
        case .unsupported:
            print("Bluetooth Low Energy is not supported on this device.")
        default:
            print("Peripheral Manager state: \(peripheral.state.rawValue)")
        }
    }
    
    // MARK: - Setup GATT Server
    private func setupGATTServer() {
        print("setupGATTServer")
        // Define a characteristic
        let characteristic = CBMutableCharacteristic(
            type: customCharacteristicUUID,
            properties: [.read, .write], // Allow read and write
            value: nil, // No initial value
            permissions: [.readable, .writeable]
        )
        
        // Define a service and add the characteristic
        let service = CBMutableService(type: customServiceUUID, primary: true)
        service.characteristics = [characteristic]
        
        // Add the service to the peripheral manager
        peripheralManager?.add(service)
        print("Custom service and characteristic added.")
    }
    
    // MARK: - Start Advertising
    func startAdvertising() {
        print("startAdvertising")
        guard let peripheralManager = peripheralManager, peripheralManager.state == .poweredOn else {
            print("Cannot start advertising. Bluetooth is not powered on.")
            return
        }
        
        let advertisementData: [String: Any] = [
            CBAdvertisementDataLocalNameKey: "Custom GATT server",
            CBAdvertisementDataServiceUUIDsKey: [customServiceUUID]
        ]
        
        peripheralManager.startAdvertising(advertisementData)
        isAdvertising = true
        print("Started advertising GATT server.")
    }
    
    // MARK: - Stop Advertising
    func stopAdvertising() {
        print("stopAdvertising")
        peripheralManager?.stopAdvertising()
        isAdvertising = false
        print("Stopped advertising GATT server.")
    }
    
    // MARK: - Respond to Read Requests
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("peripheralManager")
        if request.characteristic.uuid == customCharacteristicUUID {
            let responseValue = "Hello, CLIENT!".data(using: .utf8)
            request.value = responseValue
            peripheral.respond(to: request, withResult: .success)
            alertMessage = "Received client HELLO message"
            showAlert = true
            print("Responded to read request with value: Hello, Client!")
        } else {
            peripheral.respond(to: request, withResult: .attributeNotFound)
        }
    }
    
    // MARK: - Respond to Write Requests
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("peripheralManager")
        for request in requests {
            if request.characteristic.uuid == customCharacteristicUUID {
                if let value = request.value {
                    let receivedValue = String(data: value, encoding: .utf8) ?? "Unknown"
                    alertMessage = "Received client WRITE message: \(receivedValue)"
                    showAlert = true
                    print("Received write request with value: \(receivedValue)")
                }
                peripheral.respond(to: request, withResult: .success)
            } else {
                peripheral.respond(to: request, withResult: .attributeNotFound)
            }
        }
    }
}

