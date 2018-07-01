//
//  AppSettingsModel.swift
//  UpControl
//
//  Created by J.A. Korten on 15-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import UIKit

class AppSettings {
    
    enum cellType {
        case SettingsHeader
        case SettingsSwitchCell
        case SettingsUpDownCell
    }
    
    struct settingItem {
        var key : String
        var label : String
        var isOn : Bool
        var value : Int
        var type : cellType
        
        func getCellIdentifier() -> String {
            switch type {
                case .SettingsHeader     : return "SettingsHeader"
                case .SettingsSwitchCell : return "SettingsSwitchCell"
                case .SettingsUpDownCell : return "SettingsUpDownCell"
            }
        }
    }
    
    func valueFor(key : String) -> Int? {
        for itemIndex in 0 ..< settingsCells.count {
            let item = settingsCells[itemIndex]

            if item.key == key {
                return item.value
            }
        }
        return nil
    }
    
    func stateFor(key : String) -> Bool? {
        for itemIndex in 0 ..< settingsCells.count {
            let item = settingsCells[itemIndex]
            
            if item.key == key {
                return item.isOn
            }
        }
        return nil
    }
    
    var settingsCells : [settingItem] = []
    
    init() {
        let autoConnectItem = settingItem(key: "autoConnect", label: "Automatically Connect", isOn: true, value: 0, type : .SettingsSwitchCell)
        let autoReconnectItem = settingItem(key: "autoReconnect", label: "Automatically Reconnect", isOn: true, value: 0, type : .SettingsSwitchCell)
        let autoColoringtItem = settingItem(key: "autoColoring", label: "Automatic LED Coloring", isOn: true, value: 0, type : .SettingsSwitchCell)
        let autoShowSmartHubItem = settingItem(key: "showSmartHub", label: "Show Connected Motor(s)", isOn: true, value: 0, type : .SettingsSwitchCell)
        let speedIncrementItem = settingItem(key: "incrementSpeed", label: "Speed Incrementation Steps", isOn: false, value: 5, type : .SettingsUpDownCell)
        let rampSpeedItem = settingItem(key: "rampSpeedUpDown", label: "Gradually Ramp Speed Up/Down", isOn: true, value: 0, type : .SettingsSwitchCell)
        let gradualStop = settingItem(key: "gradualStops", label: "Gradually Stopping", isOn: true, value: 0, type : .SettingsSwitchCell)

        self.settingsCells.append(autoConnectItem)
        self.settingsCells.append(autoReconnectItem)
        self.settingsCells.append(autoColoringtItem)
        self.settingsCells.append(autoShowSmartHubItem)
        self.settingsCells.append(speedIncrementItem)
        self.settingsCells.append(rampSpeedItem)
        self.settingsCells.append(gradualStop)


        for itemIndex in 0 ..< settingsCells.count {
            var item = settingsCells[itemIndex]
            if item.type == .SettingsSwitchCell {
                if UserDefaults.standard.object(forKey: item.key) != nil {
                    item.isOn = UserDefaults.standard.bool(forKey: item.key)
                }
            } else if item.type == .SettingsUpDownCell {
                if UserDefaults.standard.object(forKey: item.key) != nil {
                    item.value = UserDefaults.standard.integer(forKey: item.key)
                }
            }
            settingsCells[itemIndex] = item
        }
        
    }
    
    func saveContext() {
        for itemIndex in 0 ..< settingsCells.count {
            let item = settingsCells[itemIndex]
            if item.type == .SettingsSwitchCell {
                UserDefaults.standard.set(item.isOn, forKey: item.key)
            } else if item.type == .SettingsUpDownCell {
                UserDefaults.standard.set(item.value, forKey: item.key)
            }
        }
    }
    
}
