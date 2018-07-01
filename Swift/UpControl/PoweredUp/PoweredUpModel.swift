//
//  PoweredUpModel.swift
//  UpControl
//
//  Created by J.A. Korten on 14-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import UIKit
import CoreBluetooth

enum motorHUBStates {
    case unavailable
    case motorA
    case motorB
    case motorAB
    case motorsNC
}

class PoweredUpModel {
   
    var colorSettings = [Int: String]()
    let bleHelper = BLEHelper()
    
    var motorHubState : motorHUBStates

    let autoConnect = true
    let showHub = true
    
    var motorA = false
    var motorB = false
    
    lazy var poweredUpMessageHelper : PoweredUpMessageHelper = PoweredUpMessageHelper(model : self)
    
    public struct BLEHelper {
        let serviceUuid          = CBUUID(string: "00001623-1212-EFDE-1623-785FEABCD123")
        let characteristicUuid   = CBUUID(string: "00001624-1212-EFDE-1623-785FEABCD123")
        let deviceNameHandset = "Handset" // -> train remote controller
        let deviceNameHub = "HUB NO.4"  // -> train motor receiver HUB
    }
    
    func getImageForMotorState() -> UIImage {
        return getImageFor(motorState: self.motorHubState)
    }
    
    func getImageFor(motorState : motorHUBStates) -> UIImage {
        let motorStateNA = #imageLiteral(resourceName: "MotorHUB_NA")
        let motorStateA  = #imageLiteral(resourceName: "MotorHUB_A")
        let motorStateB  = #imageLiteral(resourceName: "MotorHUB_B")
        let motorStateAB = #imageLiteral(resourceName: "MotorHUB_AB")
        let motorStateNC = #imageLiteral(resourceName: "MotorHUB_NC")
        
        switch motorState {
            case .unavailable:
                return motorStateNA
            case .motorA:
                return motorStateA
            case .motorB:
                return motorStateB
            case .motorAB:
                return motorStateAB
            case .motorsNC:
                return motorStateNC
        }
    }
    
    
    func buildColorSettings() {
        colorSettings[0] = "Off"
        colorSettings[1] = "Pink"
        colorSettings[2] = "Purple"
        colorSettings[3] = "Blue"
        colorSettings[4] = "Light Blue"
        colorSettings[5] = "Cyan"
        colorSettings[6] = "Green"
        colorSettings[7] = "Yellow"
        colorSettings[8] = "Orange"
        colorSettings[9] = "Red"
        colorSettings[10] = "White"
    }
    
    enum puColors {
        case offColor
        case pinkColor
        case purpleColor
        case blueColor
        case lightBlueColor
        case cyanColor
        case greenColor
        case yellowColor
        case orangeColor
        case redColor
        case whiteColor
    }

    func getColor(color : puColors) -> UInt8 {
        switch color {
            case .offColor: return 0x00
            case .pinkColor: return 0x01
            case .purpleColor: return 0x02
            case .blueColor: return 0x03
            case .lightBlueColor: return 0x04
            case .cyanColor: return 0x05
            case .greenColor: return 0x06
            case .yellowColor: return 0x07
            case .orangeColor: return 0x08
            case .redColor: return 0x09
            case .whiteColor: return 0x10
        }
        return 0x00
    }
    
    init() {
        self.motorHubState = .unavailable
        self.buildColorSettings()
    }

    func responsesFromHub(response : String) {
        self.poweredUpMessageHelper.responsesFromHub(response: response)
    }

}

extension Notification.Name {
    static let hubUpdated = Notification.Name("hubUpdated")
    static let peripheralDisconnected = Notification.Name("peripheralDisconnected")
    static let speedUpdated = Notification.Name("speedUpdated")
}




