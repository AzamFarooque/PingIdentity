//
//  PingIdentityTransitionButton.swift
//  PingIdentity
//
//  Created by Farooque Azam on 03/12/23.
//

import UIKit

class PingIdentityTransitionButton: UIButton {
    
    // MARK: - Subviews
    
    // A view responsible for displaying dots animation during button transition
    private let dotsAnimationView = PingIdentityButtonDotsAnimationView(dotSize: .init(width: 10, height: 10), dotColor: .white, animationTime: 0.9)
    
    // MARK: - Properties
    
    // The original title of the button, saved before animation starts
    private var buttonTitle: String?
    
    // The corner radius of the button
    public var radius: CGFloat = 8.0
    
    // MARK: - Overrides
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Save the initial title of the button
        buttonTitle = title(for: .normal)
        
        // Set up the UI components
        setupUI()
    }
}

// MARK: - Setups

private extension PingIdentityTransitionButton {
    
    // Set up the appearance and constraints of the button
    private func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = radius
        
        addSubview(dotsAnimationView)
        dotsAnimationView.translatesAutoresizingMaskIntoConstraints = false
        dotsAnimationView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dotsAnimationView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        dotsAnimationView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        dotsAnimationView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        dotsAnimationView.isHidden = true
    }
}

// MARK: - Start And Stop Transition

extension PingIdentityTransitionButton {
    
    // Start the dots animation and hide the button title
    public func startAnimation() {
        setTitle(nil, for: .normal)
        isUserInteractionEnabled = false
        dotsAnimationView.isHidden = false
        dotsAnimationView.startAnimation()
    }
    
    // Stop the dots animation and restore the button title
    public func stopAnimation() {
        isUserInteractionEnabled = true
        dotsAnimationView.stopAnimation()
        dotsAnimationView.isHidden = true
        setTitle(buttonTitle, for: .normal)
    }
}
