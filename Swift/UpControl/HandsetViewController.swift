//
//  ViewController.swift
//  UpControl
//
//  Created by J.A. Korten on 14-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import UIKit

class HandsetViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var poweredUpDelegate : PoweredUpDelegate!
    
    var speedFactor = 5
    var directionReverse = false
    var increaseSpeed = true
    var targetSpeed : Int = 0
    var defaultMotor : puMotor?
    
    var rampSpeedTimer: Timer!

    
    @IBOutlet weak var directionSwitch: UISwitch!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    
    
    @IBOutlet weak var slowDownButton: RoundButton!
    @IBOutlet weak var stopButton: RoundButton!
    @IBOutlet weak var speedUpButton: RoundButton!
    
    @IBOutlet weak var hubImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        poweredUpDelegate = self.appDelegate.poweredUpDelegate
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateHubImage(notification:)), name: .hubUpdated, object: nil)
        updateHandcontrolSettings()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSpeed(notification:)), name: .speedUpdated, object: nil)

        stopButton.addTarget(self, action: #selector(multipleTap(_:event:)), for: UIControlEvents.touchDownRepeat)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateHandcontrolSettings()
    }

    func updateHandcontrolSettings() {
        
        self.hubImage.image = appDelegate.poweredUpDelegate.poweredUpModel.getImageForMotorState()
        
        switch (self.appDelegate.poweredUpDelegate.poweredUpModel.motorHubState) {
           case .unavailable: defaultMotor = nil
           case .motorA: defaultMotor = self.appDelegate.poweredUpDelegate.poweredUpMotorControl.motors[0]
           case .motorB: defaultMotor = self.appDelegate.poweredUpDelegate.poweredUpMotorControl.motors[1]
           case .motorAB: defaultMotor = self.appDelegate.poweredUpDelegate.poweredUpMotorControl.motors[0] //??! Is gok dan...
           case .motorsNC: defaultMotor = nil
        }
        
        if let showHubImage = self.appDelegate.appSettings.stateFor(key: "showSmartHub") {
            hubImage.isHidden = !showHubImage
        }
        
        if let speedF = self.appDelegate.appSettings.valueFor(key: "incrementSpeed") {
            //self.poweredUpDelegate.poweredUpMotorControl.gradualSpeedFactor = speedF
            self.speedFactor = speedF
        }

        if let gradualSpeedUpDown = self.appDelegate.appSettings.stateFor(key: "rampSpeedUpDown") {
            self.poweredUpDelegate.poweredUpMotorControl.rampingEnabled = gradualSpeedUpDown
        }
        
        if let gradualStop = self.appDelegate.appSettings.stateFor(key: "gradualStops") {
            self.poweredUpDelegate.poweredUpMotorControl.gradualStopping = gradualStop
        }
        
        if let autoColoring = self.appDelegate.appSettings.stateFor(key: "autoColoring") {
            self.poweredUpDelegate.poweredUpMotorControl.autoColoring = autoColoring
        }
        
        if appDelegate.poweredUpDelegate.systemConnectionState == .linked {
            speedLabel.text = "Power: 0%"
            slowDownButton.isEnabled = true
            speedUpButton.isEnabled = true
            stopButton.isEnabled = true

        } else {
            if (appDelegate.poweredUpDelegate.systemConnectionState == .connected || appDelegate.poweredUpDelegate.systemConnectionState == .characteristic) {
                speedLabel.text = "Connected to train"
            } else if appDelegate.poweredUpDelegate.systemConnectionState == .discovered {
                speedLabel.text = "Train was found"
            } else if appDelegate.poweredUpDelegate.systemConnectionState == .disconnected {
                speedLabel.text = "Not connected to train"
            } else if appDelegate.poweredUpDelegate.systemConnectionState == .poweredon {
                speedLabel.text = "Bluetooth is On"
            } else {
                speedLabel.text = "Setting Up..."
            }
            

            slowDownButton.isEnabled = false
            speedUpButton.isEnabled = false
            stopButton.isEnabled = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToHandset(segue:UIStoryboardSegue) {
        // back :)
    }
    
    @objc func multipleTap(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 2) {
            if let motor = defaultMotor {
                self.poweredUpDelegate.poweredUpMotorControl.issueMotorStop(motor: motor, reverse: self.directionReverse)
            }
        }
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        // 127 is omslag...
        // ToDo: motor richting meenemen (ook via instelling als switch
        // ToDo: motor huidige richting meenemen
        // Guard rond de 127
        
        if (sender.tag == 0) {
            if let motor = defaultMotor {
                if (self.poweredUpDelegate.poweredUpMotorControl.gradualStopping) {
                    // slow down gradually
                    if (self.directionReverse) {
                        self.poweredUpDelegate.poweredUpMotorControl.setMotorSpeed(motor: motor, targetSpeed: 255, reverse: self.directionReverse)
                    } else {
                        self.poweredUpDelegate.poweredUpMotorControl.setMotorSpeed(motor: motor, targetSpeed: 0, reverse: self.directionReverse)
                    }
                } else { // immediate stop
                    self.poweredUpDelegate.poweredUpMotorControl.issueMotorStop(motor: motor, reverse: self.directionReverse)
                }
            }
        }

        if ((sender.tag == 1) && (!self.directionReverse)) || ((sender.tag == 2) && (self.directionReverse)) {
            if let motor = defaultMotor {
                let desiredSpeed = Int(self.speedFactor) + Int(motor.currentSpeed)
                self.poweredUpDelegate.poweredUpMotorControl.setMotorSpeed(motor: motor, targetSpeed: desiredSpeed, reverse: self.directionReverse)
            }
            increaseSpeed = true
        }
        if ((sender.tag == 1) && (self.directionReverse)) || ((sender.tag == 2) && (!self.directionReverse)) {
            if let motor = defaultMotor {
                var desiredSpeed = Int(motor.currentSpeed) - Int(self.speedFactor)
                if (desiredSpeed < 0) {
                    desiredSpeed = 0
                }
                self.poweredUpDelegate.poweredUpMotorControl.setMotorSpeed(motor: motor, targetSpeed: desiredSpeed, reverse: self.directionReverse)
            }
            increaseSpeed = false
        }
    }

    
    @objc func updateSpeed(notification: NSNotification) {
        
        if let speed = notification.userInfo {
            if let speedInfo = speed["Speed"] {
                if speedInfo is UInt8 {
                    if let _speed = speedInfo as? UInt8 {
                        updateSpeedLabel(speed : Int(_speed), reversed : self.directionReverse)
                    }
                }
            }
        }
    }
    
    func updateSpeedLabel(speed: Int, reversed : Bool) {
        
        var s = Double(speed)
        
        var calculateSpeedPct = 100.0 / (126.0 / Double(s))
        if reversed {
            if (speed != 0) {
               calculateSpeedPct = 200.8 - (100.0 / (127.0 / Double(s)))
            } else {
                calculateSpeedPct = 0.0
            }
        }

        let iSpeedPct = Int(calculateSpeedPct * 10)
        let finalSpeed = Double(iSpeedPct) / 10.0
        self.speedLabel.text = "Power: \(finalSpeed)%"
        
        
    }
    
    @IBAction func trainDirectionSwitch(_ sender: UISwitch) {
        
        self.directionReverse = !sender.isOn
        
        if let motor = defaultMotor {
            self.poweredUpDelegate.poweredUpMotorControl.issueMotorStop(motor: motor, reverse: self.directionReverse)
            if (directionSwitch.isOn) {
                motor.currentSpeed = 0
            } else {
                motor.currentSpeed = 255
            }

        }
        if (directionSwitch.isOn) {
           self.directionLabel.text = "Forward"
        } else {
            self.directionLabel.text = "Reverse"
        }
        if appDelegate.poweredUpDelegate.systemConnectionState == .linked {
            //updateTrainSpeed(motor: 0x00, speed: 0, reverse: directionSwitch.isOn)
            updateHandcontrolSettings()
        }
    }
    
    
    
    
    

    @objc func updateHubImage(notification: NSNotification) {
        updateHandcontrolSettings()
    }
    
    func calculateSpeed(speed : UInt8, acceleration : Int, reverse: Bool) -> UInt8 {
        return calculateSpeed(speed : Int(speed), acceleration : acceleration, reverse: reverse)
    }

    func calculateSpeed(speed : Int, acceleration : Int, reverse: Bool) -> UInt8 {
        var calculatedSpeed = 0
        if !reverse {
            calculatedSpeed = speed + acceleration
            if calculatedSpeed > 127 {
                calculatedSpeed = 126
            } else if calculatedSpeed < 0 {
                calculatedSpeed = 0
            }
        } else {
            if (speed == 0) {
              calculatedSpeed = 255 - acceleration
            } else {
              calculatedSpeed = speed - acceleration
            }
            if calculatedSpeed < 128 {
                calculatedSpeed = 128
            } else if calculatedSpeed > 255 {
                calculatedSpeed = 0
            }
        }
        
        return UInt8(calculatedSpeed)
    }
    
}


/*
States:
- ble off
- 
- connected
 
 USersettings
*/
