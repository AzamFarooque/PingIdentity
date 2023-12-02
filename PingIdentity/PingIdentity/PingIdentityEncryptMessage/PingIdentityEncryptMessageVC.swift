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
    var textMessage = ""
    let current = UNUserNotificationCenter.current()
    
    // MARK: - viewDidLoad Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        askForNotificationPermission()
        notificationAddObservers()
        inputTextField.delegate = self
        inputTextField.setLeftPaddingPoints(16)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Button touch action
    
    @IBAction func didTapToSend(_ sender: Any) {
        removeKey()
        if self.inputTextField.text?.isEmpty ?? false{
            self.showToast(message: StringConstants.GenericStrings.PleaseEnterText, font: .systemFont(ofSize: 12.0))
            return
        }
        self.textMessage = self.inputTextField.text ?? ""
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
                let encryptedData = try  RSAHandler.shared.encryptRSA(Data(self.textMessage.utf8), publicKey: publicKey)
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
        // Notification observer for AppDidEnterBackground
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: Notification.Name(StringConstants.PrefKey.AppDidEnterBackground), object: nil)
        // Notification observer for AppWillTerminate
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: Notification.Name(StringConstants.PrefKey.AppWillTerminate), object: nil)
    }
    
}

extension PingIdentityEncryptMessageVC {
    
    // MARK: Deleting Saved Priavte and Public key which saved in key chain
    
    func removeKey(){
        do {
            try PingIdentityKeyChainHandler.shared.removeKeyFromKeychain(identifier: StringConstants.KeyChainKey.Privatekey)
            try PingIdentityKeyChainHandler.shared.removeKeyFromKeychain(identifier: StringConstants.KeyChainKey.secondPublicKey)
        }catch let error {
            print("removeKeyFromKeychain :" , error.localizedDescription)
        }
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
        scheduleBackgroundTask()
    }
    
    // MARK: - This method triggers when aap terminated
    
    @objc func appWillTerminate() {
        scheduleBackgroundTask()
    }
    
    // MARK: - Scheduled background task to send notification
    // After delay of 15 sec
    
    func scheduleBackgroundTask() {
        let delayInSeconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            self.sendLocalPushNotification(payload: self.payLoad!)
        }
    }
}

extension PingIdentityEncryptMessageVC {
    
    // MARK: - Notification permsission
    
    func askForNotificationPermission(){
        current.requestAuthorization(options: [.badge , .sound, .alert]) {  (granted , error) in
            if error == nil {
                print("Notificarion Granted")
            }
        }
    }
    
    // MARK: - Construct and send local notification
    
    func sendLocalPushNotification(payload: [String : Any]) {
        let content = UNMutableNotificationContent()
        content.title = StringConstants.Notification.TitleText
        content.body = StringConstants.Notification.BodyText
        content.userInfo = [StringConstants.JSONKey.Payload: payload]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let uuid = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuid , content: content, trigger: trigger)
        
        current.add(request) { error in
            if let error = error {
                print("Error scheduling local push notification: \(error)")
            }
        }
    }
}

