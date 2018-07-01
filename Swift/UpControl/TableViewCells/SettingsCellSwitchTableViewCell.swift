//
//  SettingsCellSwitchTableViewCell.swift
//  UpControl
//
//  Created by J.A. Korten on 15-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import UIKit

class SettingsCellSwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingsLabel : UILabel!
    @IBOutlet weak var settingsSwitch : UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var index = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func performCellAction(_ sender: UISwitch) {
        // do callback, maybe using notification?
        appDelegate.appSettings.settingsCells[index].isOn = sender.isOn
        
    }
    

}
