import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager?
    private var targetCharacteristic: CBCharacteristic?
    
    @Published var devices: [CBPeripheral] = []
    @Published var connectedDevice: CBPeripheral?
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Central Manager State
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on.")
        } else {
            print("Bluetooth is not available.")
        }
    }

    // MARK: - Start Scanning
    func startScanning() {
        devices.removeAll() // Clear previous devices
        if centralManager?.state == .poweredOn {
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
            print("Started scanning for devices.")
        } else {
            print("Cannot start scanning. Bluetooth is not powered on.")
        }
    }

    // MARK: - Stop Scanning
    func stopScanning() {
        centralManager?.stopScan()
        print("Stopped scanning for devices.")
    }

    // MARK: - Discover Devices
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !devices.contains(where: { $0.identifier == peripheral.identifier }) {
            devices.append(peripheral)
        }
        
        //if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
        //    print("Device Name from Advertisement: \(name)")
        //} else {
        //    print("No device name in advertisement for \(peripheral.identifier)")
        //}
    }

    // MARK: - Connect to Device
    func connect(to peripheral: CBPeripheral) {
        stopScanning()
        centralManager?.connect(peripheral, options: nil)
        peripheral.delegate = self
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = peripheral
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        
        // Discover services after connecting
        peripheral.discoverServices(nil) // Pass nil to discover all services
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
    }

    // MARK: - Peripheral Delegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Peripheral 1")
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        // Look for the GAP service (UUID: 12345678-1234-5678-1234-567812345678)
        if let services = peripheral.services {
            for service in services {
                if service.uuid == CBUUID(string: "12345678-1234-5678-1234-567812345678") {
                    print("Found GAP service")
                    // Device Name characteristic
                    peripheral.discoverCharacteristics([CBUUID(string: "a7e550c4-69d1-4a6b-9fe7-8e21e5d571b6")], for: service)
                    // Find the characteristic
                    targetCharacteristic = service.characteristics?.first(where: { $0.uuid == CBUUID(string: "a7e550c4-69d1-4a6b-9fe7-8e21e5d571b6") })
                    let serviceUUID = CBUUID(string: "12345678-1234-5678-1234-567812345678")
                    let characteristicUUID = CBUUID(string: "a7e550c4-69d1-4a6b-9fe7-8e21e5d571b6")
                    let dataToWrite = "Hello, from iPhone client!".data(using: .utf8)!
                    writeValue(to: characteristicUUID, in: serviceUUID, data: dataToWrite)
                    
                    alertMessage = "Sent write request from GATT client!"
                    showAlert = true
                } else {
                    print("Discovered service: \(service.uuid)")
                }
            }
        }
    }

    // Discover Characteristics and Read Device Name
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Peripheral 2")
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid == CBUUID(string: "00002a00-0000-1000-8000-00805f9b34fb") {
                print("Found Device Name characteristic")
                peripheral.readValue(for: characteristic) // Read the Device Name
            }
        }
    }

    // MARK: - Read Characteristic Value (Equivalent to onCharacteristicRead)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Peripheral 3")
        if let error = error {
            print("Error reading characteristic: \(error.localizedDescription)")
            return
        }
        
        if characteristic.uuid == CBUUID(string: "00002a00-0000-1000-8000-00805f9b34fb") {
            // This is the Device Name characteristic
            if let value = characteristic.value, let deviceName = String(data: value, encoding: .utf8) {
                print("Device Name: \(deviceName)")
                
                // Optionally, display the device name on the UI (via SwiftUI or other means)
                DispatchQueue.main.async {
                    // Show the device name in the UI, for example, with a Toast or alert
                    print("Device Name: \(deviceName)") // Replace this with your UI update code
                }
            }
        }
    }
    
    // MARK: - Write to a Characteristic
        func writeToCharacteristic(data: Data) {
            guard let peripheral = connectedDevice, let characteristic = targetCharacteristic else {
                print("No connected device or target characteristic")
                return
            }

            // Choose `.withResponse` or `.withoutResponse` based on your use case
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }

        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            if let error = error {
                print("Error writing value: \(error.localizedDescription)")
            } else {
                print("Successfully wrote value to characteristic \(characteristic.uuid)")
            }
        }
    
    // MARK: - Write to a Characteristic
    func writeValue(to characteristicUUID: CBUUID, in serviceUUID: CBUUID, data: Data) {
        guard let peripheral = connectedDevice else {
            print("No connected device")
            return
        }

        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }),
              let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            print("Service or characteristic not found")
            return
        }

        // Write the value
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        print("Write request sent to characteristic: \(characteristic.uuid)")
    }
    
    //let serviceUUID = CBUUID(string: "YourServiceUUID")
    //let characteristicUUID = CBUUID(string: "YourCharacteristicUUID")
    //let dataToWrite = "Hello, Peripheral!".data(using: .utf8)!
    //writeValue(to: characteristicUUID, in: serviceUUID, data: dataToWrite)

    // MARK: - Read from a Characteristic
    func readValue(from characteristicUUID: CBUUID, in serviceUUID: CBUUID) {
        guard let peripheral = connectedDevice else {
            print("No connected device")
            return
        }

        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }),
              let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            print("Service or characteristic not found")
            return
        }

        // Read the value
        peripheral.readValue(for: characteristic)
        print("Read request sent to characteristic: \(characteristic.uuid)")
    }
    
    //let serviceUUID = CBUUID(string: "YourServiceUUID")
    //let characteristicUUID = CBUUID(string: "YourCharacteristicUUID")
    //readValue(from: characteristicUUID, in: serviceUUID)


}

