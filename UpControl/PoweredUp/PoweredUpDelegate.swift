//
//  PoweredUpDelegate.swift
//  UpControl
//
//  Created by J.A. Korten on 14-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import Foundation
import CoreBluetooth

enum systemState {
    case poweredon
    case disconnected
    case connected
    case discovered
    case characteristic
    case peripheral
    case service
    case linked
}

class PoweredUpDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager!
    var peripheral:CBPeripheral!
    
    let poweredUpModel = PoweredUpModel()
    var poweredUpMotorControl : PoweredUpMotorControl!
    
    let bleHelper : PoweredUpModel.BLEHelper
    var mimickHandset = true
    
    
    var rxCharacteristic:CBCharacteristic?
    var txCharacteristic:CBCharacteristic?
    
    var bluetoothStateOn = false
    var wantsToConnect = false
    
    var systemConnectionState : systemState = .disconnected
    
    override init() {
        bleHelper = poweredUpModel.bleHelper
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        poweredUpMotorControl = PoweredUpMotorControl(poweredUpDelegate: self)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOn:
            print("Bluetooth ON")
            bluetoothStateOn = true
            self.systemConnectionState = .poweredon

            if (wantsToConnect) {
                initiateScanning()
            }
            break
        case .poweredOff:
            print("Bluetooth OFF")
            self.systemConnectionState = .disconnected

            bluetoothStateOn = false
            
            break
        default:
            break;
        }
    }
    
    func disconnect() {
        if self.peripheral != nil {
            self.centralManager.cancelPeripheralConnection(self.peripheral)
        }
    }
    
    func initiateScanning() {
        let serviceUUID = self.bleHelper.serviceUuid
        
        if (bluetoothStateOn) {
          if (self.centralManager.isScanning) {
            self.centralManager.stopScan()
          }
        }
        self.peripheral = nil
        self.txCharacteristic = nil
        self.rxCharacteristic = nil
        if (bluetoothStateOn) {
            self.centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            wantsToConnect = true
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        if let name = peripheral.name {
            print("Connected to: \(name)")
        }
        self.systemConnectionState = .connected
        self.peripheral.discoverServices([self.bleHelper.serviceUuid])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var devicename = self.bleHelper.deviceNameHandset
        if (mimickHandset) {
            devicename = self.bleHelper.deviceNameHub
        } else {
            devicename = self.bleHelper.deviceNameHandset
        }
        
        if (peripheral.name?.contains(devicename))! {
            
            self.stopScanning()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            self.systemConnectionState = .discovered
            centralManager.connect(peripheral, options: [:])

        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("Characteristics discovered")
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            let chuuid = self.bleHelper.characteristicUuid
            if thisCharacteristic.uuid == chuuid {
                rxCharacteristic = thisCharacteristic
                self.peripheral.setNotifyValue(
                    true,
                    for: thisCharacteristic
                )
                txCharacteristic = thisCharacteristic
                print("RX/TX found!")
                self.systemConnectionState = .characteristic

                NotificationCenter.default.post(name: .hubUpdated, object: nil)
            }
        }
    }
    
    
    // Question: What if we want to connect to more than one // peripherals?
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Could not connect to \(peripheral.name) [Error: \(error)]")
        self.systemConnectionState = .characteristic
        NotificationCenter.default.post(name: .peripheralDisconnected, object: nil)


    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Lost connection with \(peripheral.name) [Error: \(error)]")
        NotificationCenter.default.post(name: .hubUpdated, object: nil)
        self.systemConnectionState = .disconnected
        
        self.poweredUpModel.motorHubState = .unavailable
        NotificationCenter.default.post(name: .hubUpdated, object: nil)
        
        

        self.rxCharacteristic = nil
        self.txCharacteristic = nil
        self.peripheral = nil
        
        NotificationCenter.default.post(name: .peripheralDisconnected, object: nil)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered services")
        
        if (error != nil) {
            print("Encountered error: \(error!.localizedDescription)")
            return
        }
        // look for the characteristics we want
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([self.bleHelper.characteristicUuid], for: service)
            self.systemConnectionState = .service

        }
    }
    
    func stopScanning(){
        centralManager.stopScan()
        print("BLE Finished scanning...")
    }
    
    
    func sendMessage(message: String) {
        // send the message if BLE device is connected...
        //peripheral
        let data = message.data(using: String.Encoding.utf8)
        if let p = peripheral {
            p.writeValue(data!, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            print( "Sent \(message) to TX")
        }
        
    }
    
    // worker methods:
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        guard let data = characteristic.value else {
            return
        }
        
        var result = ""
        for element in data {
            
            result = result + "\(element) "
        }
        
        let hexString = data.hexEncodedString()
        print(hexString)
        handShake(incoming : hexString, isRemote: !mimickHandset)
        
        self.poweredUpModel.responsesFromHub(response : hexString)
        self.systemConnectionState = .linked

    }
    
    
    
    func handShake(incoming : String, isRemote : Bool) {
        
        var burstControllerA: [UInt8] = [0x05, 0x00, 0x05, 0x08, 0x05]
        var burstControllerB: [UInt8] = [0x05, 0x00, 0x05, 0x08, 0x05]
        var burstControllerC: [UInt8] = [0x04, 0x00, 0x08, 0x03]
        var burstControllerD: [UInt8] = [0x05, 0x00, 0x05, 0x30, 0x05]
        if isRemote {
            if (incoming == "0500080201") {
                greenButtonRemote(burst: burstControllerA)
            } else if (incoming == "0500080200") {
                greenButtonRemote(burst: burstControllerB)
            } else if (incoming == "04000803") {
                greenButtonRemote(burst: burstControllerC)
            } else if ((incoming == "0f0004000137000000001000000010") || (incoming == "0f0004010137000000001000000010") || (incoming == "0f0004340117000000001000000010") || (incoming == "0f00043b0114000200000002000000") || (incoming == "0f00043c0138000000001000000010") || (incoming == "0500050505") || incoming == "0500050506") {
                greenButtonRemote(burst: burstControllerD)
            } else {
                print("Unknown incoming: \(incoming)")
            }
            
        }
        
        /*
         
         0f0004000137000000001000000010
         0f0004010137000000001000000010
         0f0004340117000000001000000010
         0f00043b0114000200000002000000
         0f00043c0138000000001000000010
         
         0500050505
         0500050506
         
         */
    }
    
    func greenButton() {
        
        // Old stuff:  needs to be refactored...
        
        /*
         Received: 5 0 8 2 1
         0500080201
         Received: 5 0 8 2 0
         0500080200
         Received: 4 0 8 3
         04000803
         */
        
        var burstA: [UInt8] = [0x05, 0x00, 0x08, 0x32, 0x02, 0x01]
        var burstB: [UInt8] = [0x05, 0x00, 0x08, 0x32, 0x02, 0x00]
        var burstC: [UInt8] = [0x04, 0x00, 0x08, 0x03]
        
        // See: https://github.com/JorgePe/BOOSTreveng/blob/master/RGB_LED.md
        // And it works for the train HUB as well!
        
        
        
        if let p = peripheral {
            p.writeValue(Data(bytes: burstA), for: txCharacteristic!, type: .withResponse)
        }
        if let p = peripheral {
            p.writeValue(Data(bytes: burstB), for: txCharacteristic!, type: .withResponse)
        }
        if let p = peripheral {
            p.writeValue(Data(bytes: burstC), for: txCharacteristic!, type: .withResponse)
        }
        
        if let p = peripheral {
            
            var send = "0f0004000137000000001000000010"
            var array: [UInt8] = Array(send.utf8)
            print("Sending: \(send)")
            p.writeValue(Data(bytes: array), for: txCharacteristic!, type: .withResponse)
            
            send = "0f0004010137000000001000000010"
            array = Array(send.utf8)
            print("Sending: \(send)")
            p.writeValue(Data(bytes: array), for: txCharacteristic!, type: .withResponse)
            
            send = "0f0004340117000000001000000010"
            array = Array(send.utf8)
            print("Sending: \(send)")
            p.writeValue(Data(bytes: array), for: txCharacteristic!, type: .withResponse)
            
            send = "0f00043b0114000200000002000000"
            array = Array(send.utf8)
            print("Sending: \(send)")
            p.writeValue(Data(bytes: array), for: txCharacteristic!, type: .withResponse)
            
            send = "0f00043c0138000000001000000010"
            array = Array(send.utf8)
            print("Sending: \(send)")
            p.writeValue(Data(bytes: array), for: txCharacteristic!, type: .withResponse)
            
            send = "0500050505"
            array = Array(send.utf8)
            print("Sending: \(send)")
            p.writeValue(Data(bytes: array), for: txCharacteristic!, type: .withResponse)
            
            send = "0500050506"
            array = Array(send.utf8)
            print("Sending: \(send)")
            p.writeValue(Data(bytes: array), for: txCharacteristic!, type: .withResponse)
            
            
        }
        
        
        /*
         Groene knop handset:
         0500080201
         0500080200
         04000803
         
         Vlak voor uitschakeling:
         04000230
         
         
         By aanzetten stuurt de controller:
         0f0004000102000000000000000000
         0500040100
         0f0004320117000000001000000010
         0f00043b0115000200000002000000
         0f00043c0114000200000002000000
         
         Set color reactie: 050082320a
         
         
         
         */
        
        
        
    }
    
    internal func sendColor(color : UInt8) {
        
        var value: [UInt8] = [0x08, 0x00, 0x81, 0x32, 0x11, 0x51, 0x00, 0x06]
        
        // See: https://github.com/JorgePe/BOOSTreveng/blob/master/RGB_LED.md
        // And it works for the train HUB as well!
        
        value[7] = color
        if let p = peripheral {
            p.writeValue(Data(bytes: value), for: txCharacteristic!, type: .withResponse)
        }
    }
    
    
    internal func sendMotorCommand(motor : UInt8, speed : UInt8) {
        
        
        // 0c018139110a00069B9B647f03 (Boost)
        
        var value: [UInt8] = [0x08, 0x00, 0x81, motor, 0x11, 0x51, 0x00, speed]
        
        // 0x0045 00 00
        if (self.systemConnectionState == .linked) {
            if let p = peripheral {
                p.writeValue(Data(bytes: value), for: txCharacteristic!, type: .withResponse)
            }
        }
    }
    
    /*
    
    func sendMotorCommand() {
        
        // 0c018139110a00069B9B647f03 (Boost)
        
        var value: [UInt8] = [0x08, 0x00, 0x81, 0x00, 0x11, 0x51, 0x00, 0x50]
        
        // 0x0045 00 00
        if (self.systemConnectionState == .linked) {
            if let p = peripheral {
                p.writeValue(Data(bytes: value), for: txCharacteristic!, type: .withResponse)
            }
        }
    }
    */
    
    
    func greenButtonRemote(burst : [UInt8]) {
        /*
         Received: 5 0 5 8 5
         0500050805
         Received: 5 0 5 8 5
         0500050805
         Received: 4 0 8 3
         04000803
         */
        
        
        
        
        // See: https://github.com/JorgePe/BOOSTreveng/blob/master/RGB_LED.md
        // And it works for the train HUB as well!
        
        if let p = peripheral {
            p.writeValue(Data(bytes: burst), for: txCharacteristic!, type: .withResponse)
        }
        
    }

}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
