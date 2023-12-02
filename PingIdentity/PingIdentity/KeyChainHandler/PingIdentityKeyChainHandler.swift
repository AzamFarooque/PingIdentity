//
//  PingIdentityKeyChainHandler.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation

import Foundation

final class PingIdentityKeyChainHandler {
    
    static let shared = PingIdentityKeyChainHandler()
    private init(){}
    // Function to store a SecKey in the Keychain
    func saveKeyToKeychain(key: SecKey, identifier: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecValueRef as String: key,
            kSecAttrApplicationTag as String: identifier,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA
        ]
        
        // Delete any existing key with the same identifier
        let deleteStatus = SecItemDelete(query as CFDictionary)
        
        if deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound {
            throw KeychainError.keyDeleteError(status: deleteStatus)
        }
        
        // Add the new key to the Keychain
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        
        if addStatus != errSecSuccess {
            throw KeychainError.keySaveError(status: addStatus)
        }
    }
    
    // Function to retrieve a SecKey from the Keychain
    // Function to retrieve a SecKey from the Keychain
    func getKeyFromKeychain(identifier: String) throws -> SecKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: identifier,
            kSecReturnRef as String: true
        ]
        
        var keyRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &keyRef)
        
        guard status == errSecSuccess else {
            throw KeychainError.keyLoadError(status: status)
        }
        
        // Forced cast, assuming the keyRef is a SecKey
        return keyRef as! SecKey
    }
    
    func removeKeyFromKeychain(identifier: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: identifier
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.keyDeleteError(status: status)
        }
    }
    
}

// Enum to represent Keychain-related errors
enum KeychainError: Error {
    case keySaveError(status: OSStatus)
    case keyLoadError(status: OSStatus)
    case keyDeleteError(status: OSStatus)
}
