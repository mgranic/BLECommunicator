import SwiftUI

struct MainScreen: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @StateObject private var gattServerManager = GATTServerManager()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("Start Scanning") {
                        bluetoothManager.startScanning()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("Stop Scanning") {
                        bluetoothManager.stopScanning()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                HStack {
                    VStack(spacing: 20) {
                        Text("GATT Server")
                            .font(.title)
                            .padding()
                        HStack {
                            Text(gattServerManager.isAdvertising ? "Advertising..." : "Not Advertising")
                                .foregroundColor(gattServerManager.isAdvertising ? .green : .red)
                                .font(.headline)

                            Button(action: {
                                if gattServerManager.isAdvertising {
                                    gattServerManager.stopAdvertising()
                                } else {
                                    gattServerManager.startAdvertising()
                                }
                            }) {
                                Text(gattServerManager.isAdvertising ? "Stop Advertising" : "Start Advertising")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(gattServerManager.isAdvertising ? Color.red : Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()

                List(bluetoothManager.devices, id: \.identifier) { device in
                    Button(action: {
                        bluetoothManager.connect(to: device)
                    }) {
                        HStack {
                            Text("\(device.name ?? "Unknown Device") --- \(device.identifier)")
                            if bluetoothManager.connectedDevice == device {
                                Spacer()
                                Text("Connected")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .navigationTitle("Bluetooth Devices")
            }
        }
        .alert(isPresented: $gattServerManager.showAlert) {
            Alert(title: Text(gattServerManager.alertMessage))
        }
    }
}
