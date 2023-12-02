//
//  PingIdentityStringConstant.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation


struct StringConstants {
    
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
        
    }
    
    struct Notification {
        static let TitleText = "Encrypted Message Received"
        static let BodyText = "Tap to decrypt and view the message"
    }
    
    struct PrefKey {
        static let AppWillTerminate = "AppWillTerminate"
        static let AppDidEnterBackground = "AppDidEnterBackground"
        static let NotificationTapPushMoveDecryptVC = "NotificationTapPushMoveDecryptVC"
    }
    
    struct KeyChainKey {
        static let Privatekey = "com.example.privatekey"
        static let secondPublicKey = "com.example.secondPublicKey"
    }
    
    struct JSONKey {
        static let EncryptedString = "encryptedString"
        static let Signature = "signature"
        static let Payload = "payload"
        
    }
    
}
