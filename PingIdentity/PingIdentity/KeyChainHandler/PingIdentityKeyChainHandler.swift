//
//  PingIdentityKeyChainHandler.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation

// MARK: - PingIdentityKeyChainHandler Class

final class PingIdentityKeyChainHandler {
    
    // Singleton instance of PingIdentityKeyChainHandler
    static let shared = PingIdentityKeyChainHandler()
    private init(){} // Private initializer to enforce singleton pattern
    
    // MARK: - Save SecKey to Keychain
    
    /// Saves a SecKey to the Keychain with a specified identifier.
    ///
    /// - Parameters:
    ///   - key: The SecKey to be saved.
    ///   - identifier: The unique identifier for the Keychain entry.
    /// - Throws: A KeychainError if the key saving operation fails.
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
    
    // MARK: - Retrieve SecKey from Keychain
    
    /// Retrieves a SecKey from the Keychain using a specified identifier.
    ///
    /// - Parameter identifier: The unique identifier for the Keychain entry.
    /// - Returns: The retrieved SecKey.
    /// - Throws: A KeychainError if the key retrieval operation fails.
    func getKeyFromKeychain(identifier: String) throws -> SecKey {
        // Keychain query parameters
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
    
    // MARK: - Remove SecKey from Keychain
    
    /// Removes a SecKey from the Keychain using a specified identifier.
    ///
    /// - Parameter identifier: The unique identifier for the Keychain entry.
    /// - Throws: A KeychainError if the key removal operation fails.
    func removeKeyFromKeychain(identifier: String) throws {
        // Keychain query parameters
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
    
    // MARK: - Remove All Keys
    
    /// Removes all saved private and public keys from the Keychain.
    func removeAllKey(){
        do {
            try PingIdentityKeyChainHandler.shared.removeKeyFromKeychain(identifier: StringConstants.KeyChainKey.Privatekey)
            try PingIdentityKeyChainHandler.shared.removeKeyFromKeychain(identifier: StringConstants.KeyChainKey.secondPublicKey)
        }catch let error {
            print("removeKeyFromKeychain :" , error.localizedDescription)
        }
    }
    
}

// MARK: - KeychainError Enum

/// Enum to represent Keychain-related errors
enum KeychainError: Error {
    case keySaveError(status: OSStatus)
    case keyLoadError(status: OSStatus)
    case keyDeleteError(status: OSStatus)
}
