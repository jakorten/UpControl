//
//  SettingsCellUpDownTableViewCell.swift
//  UpControl
//
//  Created by J.A. Korten on 16-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import UIKit

class SettingsCellUpDownTableViewCell: UITableViewCell {
    
    var index = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var incrementalSlider: UISlider!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func sliderChange(_ sender: UISlider) {
        appDelegate.appSettings.settingsCells[index].value = Int(sender.value)
        sliderValueLabel.text = "\(Int(sender.value))x"
    }

}
