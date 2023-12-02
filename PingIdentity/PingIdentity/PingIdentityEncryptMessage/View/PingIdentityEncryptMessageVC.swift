//
//  Example.swift
//  PingIdentity
//
//  Created by Farooque Azam on 30/11/23.
//

import Foundation
import UIKit

class PingIdentityEncryptMessageVC: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var biometricEnableAndDisabledLbl: UILabel!
    let viewModel = PingIdentityEncryptMessageViewModel()
    // InputTextField IBOutlet
    @IBOutlet weak var inputTextField: UITextField!
    // Payload
    var payLoad : [String : Any]?
    var isBiometricRequired : Bool = false
    
    @IBOutlet weak var biometricEnableAndDisableSwitch: UISwitch!
    // MARK: - viewDidLoad Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocalNotificationManager.askForNotificationPermission()
        notificationAddObservers()
        inputTextField.delegate = self
        inputTextField.setLeftPaddingPoints(16)
        navigationController?.navigationBar.isTranslucent = true
        isBiometricRequired = UserDefaults.standard.bool(forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable)
        isBiometricRequired ?  biometricEnableAndDisableSwitch.setOn(true, animated: false) : biometricEnableAndDisableSwitch.setOn(false, animated: false)
        biometricEnableAndDisabledLbl.text = isBiometricRequired ? StringConstants.GenericStrings.BiometricEnabledText : StringConstants.GenericStrings.BiometricDisableText
        
        sendButton.layer.cornerRadius = 8
        
    }
    
    deinit {
        clearObserver()
    }
    
    // MARK: - Button touch action
    
    @IBAction func didTapToEnableAndDisableFaceId(_ sender: UISwitch) {
        sender.isOn ? UserDefaults.standard.set(true , forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable) : UserDefaults.standard.set(false , forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable)
        isBiometricRequired = UserDefaults.standard.bool(forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable)
        biometricEnableAndDisabledLbl.text = isBiometricRequired ? StringConstants.GenericStrings.BiometricEnabledText : StringConstants.GenericStrings.BiometricDisableText
    }
    
    @IBAction func didTapToSend(_ sender: Any) {
        HapticTouch.addHapticTouch(style: .light)
        PingIdentityKeyChainHandler.shared.removeAllKey()
        if self.inputTextField.text?.isEmpty ?? false{
            self.showToast(message: StringConstants.GenericStrings.PleaseEnterText, font: .systemFont(ofSize: 12.0))
            return
        }
        self.inputTextField.resignFirstResponder()
        self.generateRSAKeyPair()
    }
    
    // MARK: - Remove observers to avoid memory leaks
    
    func clearObserver(){
        NotificationCenter.default.removeObserver(self)
    }
}

extension PingIdentityEncryptMessageVC {
    
    // MARK: - Generate RSA Key Pair
    
    func generateRSAKeyPair(){
        viewModel.generateRSAKeyPair { [weak self ](success , error) in
            if success{
                self?.showToast(message: StringConstants.GenericStrings.KeyCreated, font: .systemFont(ofSize: 12.0))
                self?.encryptTextMessage()
            }else{
                
            }
            return
        }
    }
    
    // MARK: - Encrypt Text
    
    func encryptTextMessage(){
        guard let publicKey = viewModel.rsaKeyDataSource?.publicKey else {return}
        viewModel.encryptTextMessage(inputText: inputTextField.text ?? "", publicKey: publicKey){ [weak self] (success , error) in
            if success{
                self?.showToast(message: StringConstants.GenericStrings.MessageEncrpted, font: .systemFont(ofSize: 12.0))
                self?.generateSecondRSAKeyPair()
            }else{
                
            }
            return
        }
    }
    
    // MARK: - Create Other Set of RSA Key for Signing and verifying
    
    func generateSecondRSAKeyPair(){
        guard let encryptedData = viewModel.payloadDataSource?.encryptedData else {return}
        viewModel.generateSecondRSAKeyPair(encryptedData: encryptedData) { [weak self] (success , error) in
            if success{
                self?.showToast(message: StringConstants.GenericStrings.SecondKeyCreated, font: .systemFont(ofSize: 12.0))
                self?.signedData()
            }else{
                
            }
        }
    }
    
    // MARK: - Signin Data
    
    func signedData(){
        guard let encryptedData = viewModel.payloadDataSource?.encryptedData , let secondPrivateKey = viewModel.secondRSAKeyDataSource?.privateKey else {return}
        viewModel.signedData(encryptedData: encryptedData, secondPrivateKey: secondPrivateKey){ [weak self] (success , error) in
            if success{
                self?.showToast(message: StringConstants.GenericStrings.SignatureIsAdded, font: .systemFont(ofSize: 12.0))
                if let signature = self?.viewModel.payloadDataSource?.signature{
                    self?.payLoad = [StringConstants.JSONKey.EncryptedString : encryptedData , StringConstants.JSONKey.Signature : signature]
                }
            }else{
                
            }
        }
    }
}

extension PingIdentityEncryptMessageVC {
    
    // MARK: - Notification Observer
    
    private func notificationAddObservers(){
        // Notification observer for NotificationTapPushMoveDecryptVC
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToDecryptMessageVC(notification:)), name:NSNotification.Name(StringConstants.PrefKey.NotificationTapPushMoveDecryptVC), object: nil)
        
        // Notification observer for AppDidEnterBackground
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: Notification.Name(StringConstants.PrefKey.AppDidEnterBackground), object: nil)
        
        // Notification observer for AppWillTerminate
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: Notification.Name(StringConstants.PrefKey.AppWillTerminate), object: nil)
    }
    
}


// TextField delegates method implementaion in extesnion
extension PingIdentityEncryptMessageVC : UITextFieldDelegate{
    
    // MARK: - Textfield ShouldReturn
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// App lifecycle
extension PingIdentityEncryptMessageVC {
    
    // MARK: - This method triggers when aap move to background
    
    @objc func appDidEnterBackground() {
        print("Background")
        scheduleBackgroundTask()
    }
    
    // MARK: - This method triggers when aap terminated
    
    @objc func appWillTerminate() {
        print("Terminated")
        scheduleBackgroundTask()
    }
    
    // MARK: - Scheduled background task to send notification
    // After delay of 15 sec
    
    func scheduleBackgroundTask() {
        guard let payload = payLoad else {return}
        let delayInSeconds = 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            LocalNotificationManager.sendLocalPushNotification(payload: payload)
        }
    }
}

extension PingIdentityEncryptMessageVC {
    
    // MARK: - Navigate to second vc on push notification tap
    
    @objc func pushToDecryptMessageVC(notification:Notification) {
        if let userInfo = notification.userInfo as? [String : Any]{
            let vc = PingIdentityDecryptMessageVC(userInfo:  userInfo , isBiometricRequired: isBiometricRequired)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
