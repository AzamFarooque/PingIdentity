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
        static let KeyCreated = "Keypair created"
        static let MessageEncrpted = "String encrypted"
        static let SecondKeyCreated = "Second Key Created"
        static let SignatureIsAdded = "String signed"
        static let SignatureVerified =  "Signature verified"
        static let SignatureNotVerified =  "Signature Not Verified"
        static let TextDecrypted =  "String decrypted"
        static let TimeerCreatedForFifteenSec = "Timer created for 15 sec"
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
    
    // MARK: - RSA Error String
    
    struct RSAErrorString{
        static let KeyPairGenerationFailedText = "Couldn't generate key pair"
        static let EncryptionFailed = "Encryption failed"
        static let DecryptionFailed = "Decryption failed"
        static let SignatureCreationFailed  = "Sign-In failed"
    }
}
