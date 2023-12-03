//
//  PingIdentityStringConstant.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation


struct StringConstants {
    
    // MARK: - Generic Strings
    
    struct GenericStrings {
        static let PleaseEnterText = "Please enter Text"
        static let KeyCreated = "Key Created"
        static let MessageEncrpted = "Message Encrpted"
        static let SecondKeyCreated = "Second Key Created"
        static let SignatureIsAdded = "Signature is Added"
        static let SignatureVerified =  "Signature Verified"
        static let SignatureNotVerified =  "Signature Not Verified"
        static let TextDecrypted =  "Text Decrypted"
        static let TimeerCreatedForFifteenSec = "Timer Created for 15 sec"
        static let FaceIdAuthoriseText = "Please authorise with touch id"
        static let BiometricEnabledText = "Biometric Enabled"
        static let BiometricDisableText = "Biometric Disable"
        
    }
    
    // MARK: - Local Notification Title and Body String
    
    struct Notification {
        static let TitleText = "Encrypted Message Received"
        static let BodyText = "Tap to decrypt and view the message"
    }
    
    // MARK: - Notification Keys
    
    struct PrefKey {
        static let AppWillTerminate = "AppWillTerminate"
        static let AppDidEnterBackground = "AppDidEnterBackground"
        static let NotificationTapPushMoveDecryptVC = "NotificationTapPushMoveDecryptVC"
    }
    
    // MARK: - UserDefaults Keys
    
    struct UserDefaultKey {
        static let SwitchEnableAndDisable = "switchEnableAndDisable"
    }
    
    // MARK: - Keychain Keys
    
    struct KeyChainKey {
        static let Privatekey = "com.example.privatekey"
        static let secondPublicKey = "com.example.secondPublicKey"
    }
    
    // MARK: - JSON Keys
    
    struct JSONKey {
        static let EncryptedString = "encryptedString"
        static let Signature = "signature"
        static let Payload = "payload"
        
    }
}
