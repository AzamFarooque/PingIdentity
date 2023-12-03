//
//  PingIdentityDecryptMessageVC.swift
//  PingIdentity
//
//  Created by Farooque Azam on 01/12/23.
//

import UIKit
import LocalAuthentication

// MARK: - PingIdentityDecryptMessageVC Class

class PingIdentityDecryptMessageVC: UIViewController {
    
    // MARK: - Properties
    
    // Label to display decrypted message
    let decryptMessageLbl = UILabel()
    // User information from the notification
    var userInfo : [String : Any]?
    // ViewModel for decryption
    let viewModel = PingIdentityDecryptMessageViewModel()
    
    // MARK: - Initialization
    
    init(userInfo : [String : Any] , isBiometricRequired : Bool) {
        super.init(nibName: nil, bundle: nil)
        self.userInfo = userInfo
        if isBiometricRequired{
            // Authorize using Face ID if required
            authorise()
        }else{
            // Proceed to verify signature if Face ID is not required
            verifySignature()
        }
    }
    
    // MARK: - Required init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    
    deinit {
        // Remove observers to avoid memory leaks
        clearObserver()
    }
    
    // MARK: - ViewDidLoad Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: - Setup UI
    
    private func setupUI(){
        // Set up the label for displaying decrypted message
        setUpDecryptMessageLabel()
        
        // Add constraints for the label
        addConstraintsForDecryptLabel()
    }
    
    // MARK: - Remove observers to avoid memory leaks
    
    private func clearObserver(){
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: -  Setting label

extension PingIdentityDecryptMessageVC {
    
    // MARK: - Decrypt Label Setup
    
    private func setUpDecryptMessageLabel(){
        decryptMessageLbl.textAlignment = .center
        decryptMessageLbl.numberOfLines = 0
        decryptMessageLbl.font = .boldSystemFont(ofSize: 15)
        decryptMessageLbl.textColor = .black
        view.addSubview(decryptMessageLbl)
        decryptMessageLbl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Decrypt Label Constraint Setup
    
    private func addConstraintsForDecryptLabel(){
        
        // Center the label horizontally
        NSLayoutConstraint.activate([
            decryptMessageLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // Position the label above the center by 100 points
            decryptMessageLbl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            // Set left and right constraints
            decryptMessageLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            decryptMessageLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            // Set height greater than or equal to 50 points
            decryptMessageLbl.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }
}

// MARK: - Biometric

extension PingIdentityDecryptMessageVC {
    
    // MARK: - Face ID Authorization
    
    private func authorise(){
        let context = LAContext()
        var error : NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = StringConstants.GenericStrings.FaceIdAuthoriseText
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] succes, error in
                DispatchQueue.main.async {
                    guard succes , error == nil else {return}
                    // Proceed to verify signature after successful Face ID authorization
                    self?.verifySignature()
                }
            }
        }else{
            // Face ID not available or not configured
        }
        
    }
}

//MARK: - Verify Signature And Decrypt Message

extension PingIdentityDecryptMessageVC{
    
    // MARK: - Verify Signature
    
    private func verifySignature(){
        guard let payload = userInfo?[StringConstants.JSONKey.Payload] as? [String : Any] else {return}
        viewModel.verifySignature(payload: payload){ [weak self] (success , error) in
            if success{
                self?.showToast(message: StringConstants.GenericStrings.SignatureVerified, font: .systemFont(ofSize: 12.0))
                
                // Proceed to decrypt the message after successful signature verification
                self?.decryptMessage()
            }else{
                self?.showToast(message: StringConstants.GenericStrings.SignatureNotVerified, font: .systemFont(ofSize: 12.0))
            }
        }
    }
    
    // MARK: - Decrypt Message
    
    private func decryptMessage(){
        if let payload = userInfo?[StringConstants.JSONKey.Payload] as? [String : Any] , let encrpt = payload[StringConstants.JSONKey.EncryptedString] as? Data {
            viewModel.decryptMessage(encrpt: encrpt) { [weak self] (success , error) in
                if success{
                    self?.showToast(message: StringConstants.GenericStrings.TextDecrypted, font: .systemFont(ofSize: 12.0))
                    self?.decryptMessageLbl.text = self?.viewModel.decryptMessageDataSource?.decryptMessage
                }else{
                    if let errorMessage = error{
                        self?.showToast(message: errorMessage, font: .systemFont(ofSize: 12.0))
                    }
                }
            }
        }
    }
}


