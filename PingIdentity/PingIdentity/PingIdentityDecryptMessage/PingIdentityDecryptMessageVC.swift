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
    
    // MARK: - Verifying Signature
    
    func verifySignature(){
        let payload = userInfo?[StringConstants.JSONKey.Payload] as? [String : Any]
        let encryptedString = payload?[StringConstants.JSONKey.EncryptedString]
        let signature = payload?[StringConstants.JSONKey.Signature]
        if let encrpt = encryptedString , let sig = signature {
            do{
                // Verify the signature using the public key
                let secondPublicKey = try PingIdentityKeyChainHandler.shared.getKeyFromKeychain(identifier: StringConstants.KeyChainKey.secondPublicKey)
                let isSignatureValid = RSAHandler.shared.verifySignature(encrpt as! Data, signature: sig as! Data, publicKey: secondPublicKey)
                if isSignatureValid{
                    self.showToast(message: StringConstants.GenericStrings.SignatureVerified, font: .systemFont(ofSize: 12.0))
                    decryptMessage(encrpt: encrpt as! Data)
                }else{
                    self.showToast(message: StringConstants.GenericStrings.SignatureNotVerified, font: .systemFont(ofSize: 12.0))
                }
                
            }catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Decrypting Message
    
    func decryptMessage(encrpt : Data){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                // Decrypt the encrypted data using the private key
                let privateKey = try PingIdentityKeyChainHandler.shared.getKeyFromKeychain(identifier: StringConstants.KeyChainKey.Privatekey)
                let decryptedData = try RSAHandler.shared.decryptRSA(encrpt , privateKey: privateKey)
                let decryptedText = String(data: decryptedData, encoding: .utf8) ?? "Decryption failed"
                self.showToast(message: StringConstants.GenericStrings.TextDecrypted, font: .systemFont(ofSize: 12.0))
                
                self.decryptMessageLbl.text = decryptedText
                
            }catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

