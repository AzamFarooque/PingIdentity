//
//  UIColor+Extension.swift
//  PingIdentity
//
//  Created by Farooque Azam on 03/12/23.
//

import UIKit

// Extend UIColor with a custom struct to define custom colors
extension UIColor {
    
    struct CustomColor {
        // Custom color for Ping Identity, using red, green, blue, and alpha values
        static let pingIdentityColor = UIColor(red: 163/255.0, green: 53/255.0, blue: 50/255.0, alpha: 1.0)
        
        // Custom background color, using red, green, blue, and alpha values
        static let backgroundColor =  UIColor(red: 241/255.0, green: 243/255.0, blue: 242/255.0, alpha: 1.0)
    }
}
