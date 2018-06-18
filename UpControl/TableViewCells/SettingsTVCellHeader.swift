//
//  SettingsTVCellHeader.swift
//  UpControl
//
//  Created by J.A. Korten on 15-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import UIKit

class SettingsTVCellHeader: UITableViewCell {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var buttonConnectDisconnect: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(updateConnectionImage(notification:)), name: .hubUpdated, object: nil)
        //hubImage.image = appDelegate.poweredUpDelegate.poweredUpModel.getImageForMotorState()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnConnectDisconnect(_ sender: UIButton) {
        if let poweredUpDelegate = appDelegate.poweredUpDelegate {
            if poweredUpDelegate.systemConnectionState == .disconnected {
                poweredUpDelegate.initiateScanning()
            } else {
                poweredUpDelegate.disconnect()
            }
        }
    }
    
    @objc func updateConnectionImage(notification: NSNotification) {
        updateConnectionImage()
    }
    
    func updateConnectionImage() {
        if let poweredUpDelegate = appDelegate.poweredUpDelegate {
            if poweredUpDelegate.systemConnectionState == .linked {
                let image = UIImage(named: "ConnectionBreak")
                buttonConnectDisconnect.setImage(image, for: .normal)
            } else {
                let image = UIImage(named: "ConnectionMake")
                buttonConnectDisconnect.setImage(image, for: .normal)
            }
            
            
        }
    }
    
}
