//
//  HapticTouch.swift
//  PingIdentity
//
//  Created by Farooque Azam on 03/12/23.
//

import UIKit

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
