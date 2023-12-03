//
//  Extensions.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation
import UIKit

// MARK: - UITextField Extension

// Extension to UITextField to add and extend new functionality
extension UITextField {
    
    // MARK: - Set Left Padding
    
    /// Sets left padding to the UITextField.
    /// - Parameter amount: The amount of padding to be set.
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
}

// MARK: - UIViewController Extension

// Extension to UIViewController for showing toast messages
extension UIViewController {
    
    // MARK: - Show Toast Message
    
    /// Displays a toast message on the view controller.
    /// - Parameters:
    ///   - message: The message to be displayed.
    ///   - font: The font of the message.
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height/2, width: 150, height: 40))
        toastLabel.backgroundColor = UIColor.CustomColor.pingIdentityColor
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}

// MARK: - HapticTouch Class

// Class to handle haptic touch feedback
public class HapticTouch{
    
    // MARK: - Add Haptic Touch
    
    /// Adds haptic touch feedback with the specified style.
    /// - Parameter style: The style of haptic feedback.
    static func addHapticTouch(style: UIImpactFeedbackGenerator.FeedbackStyle){
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
