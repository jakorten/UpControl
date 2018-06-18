//
//  PoweredUpMessageHelper.swift
//  UpControl
//
//  Created by J.A. Korten on 14-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import Foundation

class PoweredUpMessageHelper {
    
    let poweredUpModel : PoweredUpModel
    
    init (model : PoweredUpModel) { // dependency injection
        self.poweredUpModel = model
    }
    
    func responsesFromHub(response : String) {
        var hubUpdated = false
        
        if (response == "0500040000") {
            print("Motor 0x00 was disconnected...")
            
            self.poweredUpModel.motorA = false
            if self.poweredUpModel.motorB {
                self.poweredUpModel.motorHubState = .motorB
            } else {
                self.poweredUpModel.motorHubState = .motorsNC
            }
            hubUpdated = true
        }
        
        if (response == "0f0004000102000000000000000000") {
            //0f0004000102000000000000000000
            //0f0004320117000000001000000010
            //0f00043b0115000200000002000000
            //0f00043c0114000200000002000000
            print("Motor 0x00 was connected...")
            self.poweredUpModel.motorA = true
            if self.poweredUpModel.motorB {
                self.poweredUpModel.motorHubState = .motorAB
            } else {
                self.poweredUpModel.motorHubState = .motorA
            }
            hubUpdated = true
        }
        
        if (response == "0500040100") {
            print("Motor 0x01 was disconnected...")
            self.poweredUpModel.motorB = false
            if self.poweredUpModel.motorA {
                self.poweredUpModel.motorHubState = .motorA
            } else {
                self.poweredUpModel.motorHubState = .motorsNC
            }
            hubUpdated = true
        }
        if (response == "0f0004010102000000000000000000") {
            print("Motor 0x01 was connected...")
            self.poweredUpModel.motorB = true
            if self.poweredUpModel.motorA {
                self.poweredUpModel.motorHubState = .motorAB
            } else {
                self.poweredUpModel.motorHubState = .motorB
            }
            hubUpdated = true
        }
        
        if (hubUpdated) {
            NotificationCenter.default.post(name: .hubUpdated, object: nil)
        }
        
        if (response == "050082320a") {
            print("LED state was changed...")
        }
        if (response == "050082010a") {
            print("Motor 0x01 command ACK...")
        }
        if (response == "050082000a") {
            print("Motor 0x00 command ACK...")
        }
    }
}
