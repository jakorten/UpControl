//
//  PoweredUpMotorControl.swift
//  UpControl
//
//  Created by J.A. Korten on 16-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import Foundation

class puMotor {
    let address : UInt8
    var incrementStep : UInt8
    var currentSpeed : UInt8
    var reversed = false
    var targetSpeed : UInt8 = 0
    
    init(address : UInt8) {
        self.address = address
        self.currentSpeed = 0
        self.incrementStep = 1 //
    }
    
    enum transitionState {
        case Immediate
        case SpeedUp
        case SlowDown
        case Stopping
    }
    
    var transState : transitionState = .Immediate
    
    var motorTimer : Timer!
    
    func performRampUp() {
        self.transState = .SpeedUp
    }
    
    func performRampDown() {
        self.transState = .SlowDown
    }
    
    func performRampDownStop() {
        self.transState = .Stopping
    }
    
    func setRampSpeed(newSpeed : UInt8, reverse : Bool) {
        targetSpeed = newSpeed
        if (reverse) {
            if (currentSpeed < newSpeed) {
                performRampDown()
            } else if (currentSpeed >= newSpeed) {
                performRampUp()
            }
        } else {
            if (currentSpeed < newSpeed) {
                performRampUp()
            } else if (currentSpeed >= newSpeed) {
                performRampDown()
            }
        }
    }
}

class PoweredUpMotorControl {


    let transitionSpeed = 1
    var speedFactor = 5
    var gradualSpeedFactor = 0
    var motors : [puMotor]
    let poweredUpDelegate : PoweredUpDelegate
    var rampingEnabled = false
    var gradualStopping = true
    
    var autoColoring = false
    
    var rampSpeedTimer: Timer!


    init(poweredUpDelegate : PoweredUpDelegate) { // dependency injection
        
        let motorA = puMotor(address: 0x00)
        let motorB = puMotor(address: 0x01)
        self.motors = []
        self.poweredUpDelegate = poweredUpDelegate
        self.motors.append(motorA)
        self.motors.append(motorB)
    }

    func setMotorSpeed(motor : puMotor, targetSpeed : Int, reverse : Bool) {
        self.setMotorSpeed(motor : motor, targetSpeed : targetSpeed, reverse : reverse, ramp : rampingEnabled)
    }
    
    func setMotorSpeed(motor : puMotor, targetSpeed : Int, reverse : Bool, ramp : Bool) {
        
        if (autoColoring) {
            processColors(currentSpeed: Int(motor.currentSpeed), targetSpeed: targetSpeed, reverse : reverse)
        }
        //print("Targetspeed: \(targetSpeed), Speed: \(motor.currentSpeed)")
        
        motor.reversed = reverse
        var setSpeed = targetSpeed
        
        if (reverse) {
            if (motor.currentSpeed < 127) {
                motor.currentSpeed = 255
            }
            print("Cut off when zero is implemented at changeMotorSpeed level.")
            // reason for this it at 255 the motor is not really off (makes a little buzzing noise
        }
        
        if ((setSpeed >= 127) && (!reverse)) {
            setSpeed = 126
        } else if ((setSpeed <= 0) && (!reverse)) {
            setSpeed = 0
        } else if ((setSpeed >= 255) && (reverse)) {
            setSpeed = 255
        } else if ((setSpeed <= 127) && (reverse)) {
            setSpeed = 128
        }
        //print("Set speed to: \(setSpeed)")
        
        if (ramp) {
            motor.setRampSpeed(newSpeed: UInt8(setSpeed), reverse : reverse)
            
            rampSpeedTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.transitionSpeed), target: self, selector: #selector(motorTimerTriggered), userInfo: motor, repeats: false)

        } else {
            motor.targetSpeed = UInt8(setSpeed)
            motor.currentSpeed = UInt8(setSpeed)
            changeMotorSpeed(motor: motor, speed: UInt8(setSpeed))
        }
        
        
    }
    
    func issueMotorStop(motor : puMotor, reverse : Bool) {
        var targetSpeed = 0
        if (reverse) {
            targetSpeed = 255
        }
        //print("Targetspeed: \(targetSpeed), Speed: \(motor.currentSpeed)")
        motor.currentSpeed = UInt8(targetSpeed)
        setMotorSpeed(motor : motor, targetSpeed : targetSpeed, reverse : reverse, ramp : false)

    }
    
    @objc func motorTimerTriggered() {
        guard let motor = self.rampSpeedTimer.userInfo as? puMotor else {
            return
        }
        if (autoColoring) {
            processColors(currentSpeed: Int(motor.currentSpeed), targetSpeed: Int(motor.targetSpeed), reverse : motor.reversed)
        }

        
        if ((motor.transState == .SpeedUp && motor.reversed == true) || (motor.transState == .SlowDown && motor.reversed == false)) {
            if motor.currentSpeed > motor.targetSpeed {
                motor.currentSpeed -= motor.incrementStep
                rampSpeedTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.transitionSpeed), target: self, selector: #selector(motorTimerTriggered), userInfo: motor, repeats: false)
                changeMotorSpeed(motor : motor, speed : motor.currentSpeed)

            } else {
                motor.currentSpeed = motor.targetSpeed // cut off
                motor.transState = .Immediate // reset state
            }
        } else if ((motor.transState == .SlowDown && motor.reversed == true) || (motor.transState == .SpeedUp && motor.reversed == false)) {
            if motor.currentSpeed < motor.targetSpeed {
                motor.currentSpeed += motor.incrementStep
                rampSpeedTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.transitionSpeed), target: self, selector: #selector(motorTimerTriggered), userInfo: motor, repeats: false)
                changeMotorSpeed(motor : motor, speed : motor.currentSpeed)
            } else {
                motor.currentSpeed = motor.targetSpeed // cut off
                motor.transState = .Immediate // reset state
            }
        }
    }
    
    func changeMotorSpeed(motor : puMotor, speed : UInt8) {
        if (speed == 255) {
            self.poweredUpDelegate.sendMotorCommand(motor: motor.address, speed: 0)
            // reason for this it at 255 the motor is not really off (makes a little buzzing noise
            // even in reverse we set it to 0 because of that
        } else {
           self.poweredUpDelegate.sendMotorCommand(motor: motor.address, speed: speed)
        }
        // Update UI:
        let speedInfo = ["Speed" : speed]
        NotificationCenter.default.post(name: .speedUpdated, object: nil, userInfo : speedInfo)
    }
    
    func processColors(currentSpeed: Int, targetSpeed: Int, reverse : Bool) {
        var myColor : UInt8 = 0x00
        let puModel = poweredUpDelegate.poweredUpModel
        if (!reverse) {
            if targetSpeed == 0 {
                // show red
                myColor = puModel.getColor(color: .redColor)
            } else if (currentSpeed < targetSpeed) {
                // show green
                myColor = puModel.getColor(color: .greenColor)
            } else if (currentSpeed > targetSpeed) {
                // show orange
                myColor = puModel.getColor(color: .orangeColor)
            } else {
                // show white
                myColor = puModel.getColor(color: .whiteColor)
            }
        } else {
            if targetSpeed == 255 {
                // show red
                myColor = puModel.getColor(color: .redColor)
            } else if (currentSpeed > targetSpeed) {
                // show green
                myColor = puModel.getColor(color: .greenColor)
            } else if (currentSpeed < targetSpeed) {
                // show orange
                myColor = puModel.getColor(color: .orangeColor)
            } else {
                // show white
                myColor = puModel.getColor(color: .whiteColor)
            }
        }
        self.poweredUpDelegate.sendColor(color: myColor)
    }
    
}
