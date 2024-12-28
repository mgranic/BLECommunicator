import SwiftUI

struct MainScreen: View {
    @StateObject private var sharedAlertManager = SharedAlertManager()
    @StateObject private var bluetoothManager = BluetoothManager()
    @StateObject private var gattServerManager = GATTServerManager()
    @StateObject private var sharedEventMgr = SharedBtEventManager()
    private let settingsManager = SettingManager()

    var body: some View {
        NavigationStack {
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
                //HStack {
                //    VStack(spacing: 20) {
                //        Text("GATT Server")
                //            .font(.title)
                //            .padding()
                //        HStack {
                //            Text(gattServerManager.isAdvertising ? "Advertising..." : "Not Advertising")
                //                .foregroundColor(gattServerManager.isAdvertising ? .green : .red)
                //                .font(.headline)

                //            Button(action: {
                //                if gattServerManager.isAdvertising {
                //                    gattServerManager.stopAdvertising()
                //                } else {
                //                    gattServerManager.startAdvertising()
                //                }
                //            }) {
                //                Text(gattServerManager.isAdvertising ? "Stop Advertising" : "Start Advertising")
                //                    .padding()
                //                    .foregroundColor(.white)
                //                    .background(gattServerManager.isAdvertising ? Color.red : Color.blue)
                //                    .cornerRadius(10)
                //            }
                //        }
                //    }
                //}
                //.padding()
                TabView {
                    List(bluetoothManager.devices, id: \.identifier) { device in
                        Button(action: {
                            if bluetoothManager.connectedDevice == device {
                                if (settingsManager.getOperationType() == OperationType.write) || (settingsManager.getOperationType() == OperationType.rw) {
                                    bluetoothManager.sendMessage()
                                }
                                if (settingsManager.getOperationType() == OperationType.read) || (settingsManager.getOperationType() == OperationType.rw) {
                                    bluetoothManager.readMessage()
                                }
                            } else {
                                bluetoothManager.connect(to: device)
                            }
                            //bluetoothManager.connect(to: device)
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
                    .tabItem {
                        Label("Devices", systemImage: "macbook.and.iphone")
                    }
                    
                    List(sharedEventMgr.events) { event in
                        VStack(alignment: .leading) {
                            Text(event.name)
                                .font(.headline)
                            Text(event.timestamp.formatted())
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .tabItem {
                        Label("Events", systemImage: "list.bullet")
                    }
                }
                .navigationTitle("Bluetooth Manager")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink(destination: SettingsScreen()) {
                            Label("Settings", systemImage: "gear")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                //gattServerManager.sharedAlertManager = sharedAlertManager
                //bluetoothManager.sharedAlertManager = sharedAlertManager
                
                gattServerManager.sharedEventManager = sharedEventMgr
                bluetoothManager.sharedEventManager = sharedEventMgr
            }
            .alert(isPresented: $sharedAlertManager.showAlert) {
                Alert(
                        title: Text(sharedAlertManager.alertData.title),
                        message: Text(sharedAlertManager.alertData.message),
                        dismissButton: .default(Text("OK"))
                    )
            }
            //.alert(isPresented: $bluetoothManager.showAlert) {
            //    Alert(title: Text(bluetoothManager.alertMessage))
            //}
        }
    }
}
