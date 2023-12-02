//
//  Example.swift
//  PingIdentity
//
//  Created by Farooque Azam on 30/11/23.
//

import Foundation
import UIKit

class PingIdentityEncryptMessageVC: UIViewController {
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

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Button touch action
    
    @IBAction func didTapToEnableAndDisableFaceId(_ sender: UISwitch) {
        sender.isOn ? UserDefaults.standard.set(true , forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable) : UserDefaults.standard.set(false , forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable)
        isBiometricRequired = UserDefaults.standard.bool(forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable)
    }
    
    @IBAction func didTapToSend(_ sender: Any) {
        PingIdentityKeyChainHandler.shared.removeAllKey()
        if self.inputTextField.text?.isEmpty ?? false{
            self.showToast(message: StringConstants.GenericStrings.PleaseEnterText, font: .systemFont(ofSize: 12.0))
            return
        }
        self.generateRSAKeyPair()
    }
}


extension PingIdentityEncryptMessageVC {
    
    func generateRSAKeyPair(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0){
            do {
                let (privateKey, publicKey) = try  RSAHandler.shared.generateRSAKeyPair()
                try PingIdentityKeyChainHandler.shared.saveKeyToKeychain(key: privateKey, identifier: StringConstants.KeyChainKey.Privatekey)
                self.showToast(message: StringConstants.GenericStrings.KeyCreated, font: .systemFont(ofSize: 12.0))
                self.encryptTextMessage(publicKey: publicKey)
            }catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func encryptTextMessage(publicKey : SecKey){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                let encryptedData = try  RSAHandler.shared.encryptRSA(Data((self.inputTextField.text ?? "").utf8), publicKey: publicKey)
                self.showToast(message: StringConstants.GenericStrings.MessageEncrpted, font: .systemFont(ofSize: 12.0))
                self.generateSecondRSAKeyPair(encryptedData: encryptedData)
            }catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func generateSecondRSAKeyPair(encryptedData : Data){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                let (secondPrivateKey, secondPublicKey) = try  RSAHandler.shared.generateRSAKeyPair()
                try PingIdentityKeyChainHandler.shared.saveKeyToKeychain(key: secondPublicKey, identifier: StringConstants.KeyChainKey.secondPublicKey)
                self.showToast(message: StringConstants.GenericStrings.SecondKeyCreated, font: .systemFont(ofSize: 12.0))
                self.signedData(encryptedData: encryptedData, secondPrivateKey: secondPrivateKey)
            }catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func signedData(encryptedData : Data , secondPrivateKey : SecKey){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                let signature = try  RSAHandler.shared.signData(encryptedData, privateKey: secondPrivateKey)
                self.showToast(message: StringConstants.GenericStrings.SignatureIsAdded, font: .systemFont(ofSize: 12.0))
                self.payLoad = [StringConstants.JSONKey.EncryptedString : encryptedData , StringConstants.JSONKey.Signature : signature]
            }catch let error {
                print(error.localizedDescription)
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
