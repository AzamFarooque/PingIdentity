//
//  PingIdentityDecryptMessageVC.swift
//  PingIdentity
//
//  Created by Farooque Azam on 01/12/23.
//

import UIKit
import LocalAuthentication

class PingIdentityDecryptMessageVC: UIViewController {
    let decryptMessageLbl = UILabel()
    var userInfo : [String : Any]?
    let viewModel = PingIdentityDecryptMessageViewModel()
    
    // MARK: - init
    
    init(userInfo : [String : Any] , isBiometricRequired : Bool) {
        super.init(nibName: nil, bundle: nil)
        self.userInfo = userInfo
        if isBiometricRequired{
            authorise()
        }else{
            verifySignature()
        }
    }
    
    // MARK: - Required init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - viewDidLoad Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: - Setup UI
    
    func setupUI(){
        setUpDecryptMessageLabel()
        addConstraintsForDecryptLabel()
    }
}

// Setting label
extension PingIdentityDecryptMessageVC {
    
    // MARK: - Decrypt Label Setup
    
    func setUpDecryptMessageLabel(){
        decryptMessageLbl.textAlignment = .center
        decryptMessageLbl.font = .boldSystemFont(ofSize: 15)
        decryptMessageLbl.textColor = .black
        view.addSubview(decryptMessageLbl)
        decryptMessageLbl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Decrypt Label Constraint Setup
    
    func addConstraintsForDecryptLabel(){
        
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

// Faceid method
extension PingIdentityDecryptMessageVC {
    
    // MARK: - Faceid Authorise
    
    func authorise(){
        let context = LAContext()
        var error : NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = StringConstants.GenericStrings.FaceIdAuthoriseText
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] succes, error in
                DispatchQueue.main.async {
                    guard succes , error == nil else {return}
                    self?.verifySignature()
                }
            }
        }else{
            // can not use
        }
        
    }
}

// Verify signature and decrypt message using RSA
extension PingIdentityDecryptMessageVC{
    
    func verifySignature(){
        guard let payload = userInfo?[StringConstants.JSONKey.Payload] as? [String : Any] else {return}
        viewModel.verifySignature(payload: payload){ [weak self] (success , error) in
            if success{
                self?.showToast(message: StringConstants.GenericStrings.SignatureVerified, font: .systemFont(ofSize: 12.0))
                self?.decryptMessage()
            }else{
                self?.showToast(message: StringConstants.GenericStrings.SignatureNotVerified, font: .systemFont(ofSize: 12.0))
            }
        }
    }
    
    func decryptMessage(){
        if let payload = userInfo?[StringConstants.JSONKey.Payload] as? [String : Any] , let encrpt = payload[StringConstants.JSONKey.EncryptedString] as? Data {
            viewModel.decryptMessage(encrpt: encrpt) { [weak self] (success , error) in
                if success{
                    self?.showToast(message: StringConstants.GenericStrings.TextDecrypted, font: .systemFont(ofSize: 12.0))
                    self?.decryptMessageLbl.text = self?.viewModel.decryptMessageDataSource?.decryptMessage
                }else{
                    
                }
            }
        }
    }
}


