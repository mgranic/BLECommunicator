import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager?
    @Published var devices: [CBPeripheral] = []
    @Published var connectedDevice: CBPeripheral?

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
        
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("Device Name from Advertisement: \(name)")
        } else {
            print("No device name in advertisement for \(peripheral.identifier)")
        }
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
        
        // Look for the GAP service (UUID: 00001800-0000-1000-8000-00805f9b34fb)
        if let services = peripheral.services {
            for service in services {
                if service.uuid == CBUUID(string: "00001800-0000-1000-8000-00805f9b34fb") {
                    print("Found GAP service")
                    peripheral.discoverCharacteristics([CBUUID(string: "00002a00-0000-1000-8000-00805f9b34fb")], for: service) // Device Name characteristic
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
}

