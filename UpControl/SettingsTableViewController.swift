//
//  SettingsTableViewController.swift
//  UpControl
//
//  Created by J.A. Korten on 15-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 60;
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateConnectionImage(notification:)), name: .hubUpdated, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.appDelegate.appSettings.settingsCells.count + 1 // + our extra header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let appSettings = self.appDelegate.appSettings

        
        var cell : UITableViewCell?
        if indexPath.row == 0 {
            let myHeaderCell : SettingsTVCellHeader = tableView.dequeueReusableCell(withIdentifier: "SettingsHeader", for: indexPath) as! SettingsTVCellHeader
            myHeaderCell.updateConnectionImage()
            cell = myHeaderCell
        } else {
            let item = appSettings.settingsCells[indexPath.row - 1] // -1 -> Header
            if item.type == .SettingsSwitchCell  {
                let mySettingsCell : SettingsCellSwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchCell", for: indexPath) as! SettingsCellSwitchTableViewCell
                // index meegeven aan die cell, dan callback als flip geswitcht wordt...
                
                mySettingsCell.index = indexPath.row - 1
                mySettingsCell.settingsSwitch.isOn = item.isOn
                mySettingsCell.settingsLabel.text = item.label

                cell = mySettingsCell
            } else if item.type == .SettingsUpDownCell {
                let mySettingsCell : SettingsCellUpDownTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsUpDownCell", for: indexPath) as! SettingsCellUpDownTableViewCell
                // index meegeven aan die cell, dan callback als flip geswitcht wordt...
                
                mySettingsCell.index = indexPath.row - 1
                mySettingsCell.incrementalSlider.value = Float(item.value)
                mySettingsCell.settingsLabel.text = item.label
                mySettingsCell.sliderValueLabel.text = "\(item.value)x"

                cell = mySettingsCell
                
                
            }

        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120.0
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    
    @objc func updateConnectionImage(notification: NSNotification) {

       tableView.reloadData()
    }

}
