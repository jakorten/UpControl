//
//  TactileButton.swift
//  UpControl
//
//  Created by J.A. Korten on 16-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import UIKit

@IBDesignable public class TactileButton: UIButton {

    var tactileFeedbackEnabled = false
    
    @IBInspectable var tactileFeedback: Bool = false {
        didSet {
            tactileFeedbackEnabled = tactileFeedback
        }
    }
        
    override public func layoutSubviews() {
        super.layoutSubviews()

        self.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
        
    @objc func tapped() {
        if tactileFeedbackEnabled {
            if self.state == .normal {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                //generator.impactOccurred()
            } else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                
            }
        }
            
        /*
         i += 1
         print("Running \(i)")
         
         switch i {
         case 1:
         let generator = UINotificationFeedbackGenerator()
         generator.notificationOccurred(.error)
         
         case 2:
         let generator = UINotificationFeedbackGenerator()
         generator.notificationOccurred(.success)
         
         case 3:
         let generator = UINotificationFeedbackGenerator()
         generator.notificationOccurred(.warning)
         
         case 4:
         let generator = UIImpactFeedbackGenerator(style: .light)
         generator.impactOccurred()
         
         case 5:
         let generator = UIImpactFeedbackGenerator(style: .medium)
         generator.impactOccurred()
         
         case 6:
         let generator = UIImpactFeedbackGenerator(style: .heavy)
         generator.impactOccurred()
         
         default:
         let generator = UISelectionFeedbackGenerator()
         generator.selectionChanged()
         i = 0
         }*/
    }
        
        
}



