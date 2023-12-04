//
//  Example.swift
//  PingIdentity
//
//  Created by Farooque Azam on 30/11/23.
//

import Foundation
import UIKit

// MARK: - PingIdentityEncryptMessageVC Class

class PingIdentityEncryptMessageVC: UIViewController {
    
    // MARK: IBOutlets
    
    // Reference to the send button with a custom transition
    @IBOutlet weak var sendButton: PingIdentityTransitionButton!
    // Switch to enable or disable biometric functionality
    @IBOutlet weak var biometricEnableAndDisableSwitch: UISwitch!
    // Input text field for user input
    @IBOutlet weak var inputTextField: UITextField!
    // Label indicating whether biometric functionality is enabled or disabled
    @IBOutlet weak var biometricEnableAndDisabledLbl: UILabel!
    
    // MARK: Properties
    
    // VieWmodel
    private let viewModel = PingIdentityEncryptMessageViewModel()
    // Payload
    private var payLoad : [String : Any]?
    // Flag indicating whether biometric functionality is enabled or disabled
    private var isBiometricEnabled : Bool = false
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.CustomColor.backgroundColor
        
        // Requesting notification permission
        LocalNotificationManager.askForNotificationPermission()
        
        // Adding observers for notifications
        notificationAddObservers()
        
        // Setting up inputTextField delegate
        inputTextField.delegate = self
        inputTextField.setLeftPaddingPoints(8)
        
        // Configuring navigation bar
        navigationController?.navigationBar.isTranslucent = true
        
        // Check and update the UI components related to biometric settings based on user preferences.
        updateBiometricUIBasedOnUserPreferences()
        
        // Configuring button appearance
        sendButton.layer.cornerRadius = 8
        
    }
    
    // MARK: - Deinit
    
    deinit {
        // Removing observers to avoid memory leaks
        clearObserver()
    }
    
    // MARK: - Biometric Switch Enable or Disable Action
    
    @IBAction func didTapToEnableAndDisableBiometric(_ sender: UISwitch) {
        // Updating user defaults based on switch state
        sender.isOn ? UserDefaults.standard.set(true , forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable) : UserDefaults.standard.set(false , forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable)
        
        // Updating isBiometricEnabled based on switch state
        isBiometricEnabled = UserDefaults.standard.bool(forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable)
        
        // Updating biometricEnableAndDisabledLbl based on switch state
        biometricEnableAndDisabledLbl.text = isBiometricEnabled ? StringConstants.GenericStrings.BiometricEnabledText : StringConstants.GenericStrings.BiometricDisableText
    }
    
    // MARK: - Button Touch Action
    
    @IBAction func didTapToSend(_ sender: Any) {
        // Adding haptic touch feedback
        HapticTouch.addHapticTouch(style: .light)
        
        // Removing all keys from the keychain
        PingIdentityKeyChainHandler.shared.removeAllKey()
        
        // Validating input text
        guard let inputText = inputTextField.text, !inputText.isEmpty else {
            showToast(message: StringConstants.GenericStrings.PleaseEnterText, font: .systemFont(ofSize: 12.0))
            return
        }
        
        // Button progress
        sendButton.startAnimation()
        
        // Hiding the keyboard
        self.inputTextField.resignFirstResponder()
        
        // Generating RSA key pair
        self.generateRSAKeyPair()
    }
    
    // MARK: - Remove Observers
    
    private func clearObserver(){
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - RSA Key Pair Generation , Encryption and Sign-Data


extension PingIdentityEncryptMessageVC {
    
    // MARK: - Generate RSA Key Pair
    
    /// Generates an RSA key pair and proceeds to encrypt the input text.
    private func generateRSAKeyPair(){
        viewModel.generateRSAKeyPair { [weak self ](success , error) in
            if success{
                self?.showToast(message: StringConstants.GenericStrings.KeyCreated, font: .systemFont(ofSize: 12.0))
                self?.encryptTextMessage()
            }else{
                if let errorMessage = error{
                    self?.showToast(message: errorMessage, font: .systemFont(ofSize: 12.0))
                }
            }
        }
    }
    
    // MARK: - Encrypt Text
    
    /// Encrypts the input text using the generated RSA public key.
    private func encryptTextMessage(){
        guard let publicKey = viewModel.rsaKeyDataSource?.publicKey else {return}
        viewModel.encryptTextMessage(inputText: inputTextField.text ?? "", publicKey: publicKey){ [weak self] (success , error) in
            if success{
                self?.showToast(message: StringConstants.GenericStrings.MessageEncrpted, font: .systemFont(ofSize: 12.0))
                self?.generateSecondRSAKeyPair()
            }else{
                if let errorMessage = error{
                    self?.showToast(message: errorMessage, font: .systemFont(ofSize: 12.0))
                }
            }
        }
    }
    
    // MARK: - Generate Second Set of RSA Keys for Signing and Verifying
    
    /// Generates a second set of RSA keys for signing and verifying.
    private func generateSecondRSAKeyPair(){
        guard let encryptedData = viewModel.payloadDataSource?.encryptedData else {return}
        viewModel.generateSecondRSAKeyPair(encryptedData: encryptedData) { [weak self] (success , error) in
            if success{
                self?.signedData()
            }else{
                if let errorMessage = error{
                    self?.showToast(message: errorMessage, font: .systemFont(ofSize: 12.0))
                }
            }
        }
    }
    
    // MARK: - Sign Data
    
    /// Signs the encrypted data using the second set of RSA private key.
    private func signedData(){
        guard let encryptedData = viewModel.payloadDataSource?.encryptedData , let secondPrivateKey = viewModel.secondRSAKeyDataSource?.privateKey else {return}
        viewModel.signedData(encryptedData: encryptedData, secondPrivateKey: secondPrivateKey){ [weak self] (success , error) in
            if success{
                self?.showToast(message: StringConstants.GenericStrings.SignatureIsAdded, font: .systemFont(ofSize: 12.0))
                if let signature = self?.viewModel.payloadDataSource?.signature{
                    
                    // Payload created to send notification
                    self?.payLoad = [StringConstants.JSONKey.EncryptedString : encryptedData , StringConstants.JSONKey.Signature : signature]
                    
                    // Show toast and stop button animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                        self?.showToast(message: StringConstants.GenericStrings.TimeerCreatedForFifteenSec, font: .systemFont(ofSize: 12.0))
                        self?.sendButton.stopAnimation()
                    }
                }
            }else{
                if let errorMessage = error{
                    self?.showToast(message: errorMessage, font: .systemFont(ofSize: 12.0))
                }
            }
        }
    }
}

// MARK: Biometric UI Update

extension PingIdentityEncryptMessageVC {
    
    /// Updates the UI components related to biometric settings based on user preferences.
    private func updateBiometricUIBasedOnUserPreferences(){
        // Retrieve the biometric enable/disable status from UserDefaults
        isBiometricEnabled = UserDefaults.standard.bool(forKey: StringConstants.UserDefaultKey.SwitchEnableAndDisable)
        
        // Set the state of the biometric enable/disable switch based on the retrieved status
        isBiometricEnabled ?  biometricEnableAndDisableSwitch.setOn(true, animated: false) : biometricEnableAndDisableSwitch.setOn(false, animated: false)
        
        // Update the label text based on the biometric enable/disable status
        biometricEnableAndDisabledLbl.text = isBiometricEnabled ? StringConstants.GenericStrings.BiometricEnabledText : StringConstants.GenericStrings.BiometricDisableText
    }
}

// MARK: - Notification Observers

extension PingIdentityEncryptMessageVC {
    
    // MARK: - Notification Observer Setup
    
    /// Sets up observers for various notifications related to the application lifecycle and user interactions.
    private func notificationAddObservers(){
        
        // Notification observer for navigating to DecryptMessageVC on tap
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToDecryptMessageVC(notification:)), name:NSNotification.Name(StringConstants.PrefKey.NotificationTapPushMoveDecryptVC), object: nil)
        
        // Notification observer for handling app entering the background
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: Notification.Name(StringConstants.PrefKey.AppDidEnterBackground), object: nil)
        
        // Notification observer for handling app termination
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: Notification.Name(StringConstants.PrefKey.AppWillTerminate), object: nil)
    }
    
}


// MARK: - Extension for Text Field Delegates

extension PingIdentityEncryptMessageVC : UITextFieldDelegate{
    
    // MARK: - Textfield ShouldReturn
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// MARK: - App Lifecycle and Scheduled Background Methods

extension PingIdentityEncryptMessageVC {
    
    // MARK: - Application Entering Background
    
    /// This method is triggered when the app moves to the background.
    @objc private func appDidEnterBackground() {
        // Schedule a background task to send a local notification
        scheduleBackgroundTask(delay : 15)
    }
    
    // MARK: - Application Will Terminate
    
    /// This method is triggered when the app is terminated.
    @objc private func appWillTerminate() {
        // Schedule a background task to send a local notification
        scheduleBackgroundTask(delay : 15)
    }
    
    // MARK: - Scheduled Background Task
    
    /// Schedules a background task to send a local notification after a delay of 15 seconds.
    private func scheduleBackgroundTask(delay : TimeInterval) {
        // Ensure that there is a payload to include in the notification
        guard let payload = self.payLoad else {return}
        
        DispatchQueue.global().async{
            // Send a local push notification with the provided payload
            LocalNotificationManager.sendLocalPushNotification(payload: payload , delay: delay)
            
            // Clear the payload after sending the notification
            self.payLoad = nil
        }
    }
}

// MARK: - Navigation on Push Notification Tap

extension PingIdentityEncryptMessageVC {
    
    // MARK: - Navigate to Second View Controller on Push Notification Tap
    
    /// Handles navigation to the second view controller when the user taps on a push notification.
    ///
    /// - Parameters:
    ///   - notification: The notification containing user information.
    @objc private func pushToDecryptMessageVC(notification:Notification) {
        // Check if the notification contains user information
        if let userInfo = notification.userInfo as? [String : Any]{
            // Create an instance of PingIdentityDecryptMessageVC with user information and biometric requirement status
            let viewController = PingIdentityDecryptMessageVC(userInfo:  userInfo , isBiometricEnabled: isBiometricEnabled)
            
            // Push the second view controller onto the navigation stack
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
