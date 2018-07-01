//
//  RoundButton.swift
//  RoundButtonExample
//
//  Created by J.A. Korten on 26-02-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import UIKit

@IBDesignable public class RoundButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var tactileFeedbackEnabled = false
    
    @IBInspectable var borderColor: UIColor = UIColor.blue {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.2 {
        didSet {
            layer.cornerRadius = cornerRadius * bounds.size.width
        }
    }
    
    @IBInspectable var tactileFeedback: Bool = false {
        didSet {
            tactileFeedbackEnabled = tactileFeedback
        }
    }
    
    @IBInspectable var adjustFontSize : Bool = true {
        didSet {
           self.titleLabel?.adjustsFontSizeToFitWidth = adjustFontSize
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius * bounds.size.width
        self.titleLabel?.textAlignment = .center
        clipsToBounds = true
        
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


