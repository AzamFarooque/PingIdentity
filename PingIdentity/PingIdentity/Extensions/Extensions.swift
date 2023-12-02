//
//  Extensions.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation
import UIKit

// Textfield extension to add and extend new functionality
extension UITextField {
    
    // MARK: - Method to provide left padding
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
}
