//
//  RSAHandler.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation

// MARK: - RSAHandler Class

final class RSAHandler{
    
    // Singleton instance of RSAHandler
    static let shared = RSAHandler()
    private init(){} // Private initializer to enforce singleton pattern
    
    // MARK: - RSA Key Pair Generation
    
    /// Generates a pair of RSA public and private keys.
    ///
    /// - Returns: A tuple containing the generated private and public keys.
    /// - Throws: An error if key generation fails.
    func generateRSAKeyPair() throws -> (SecKey, SecKey) {
        var error: Unmanaged<CFError>?
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 1024
        ]
        
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw error!.takeRetainedValue() as Error
        }
        
        return (privateKey, publicKey)
    }
    
    // MARK: - RSA Encryption
    
    /// Encrypts the provided data using the given RSA public key.
    ///
    /// - Parameters:
    ///   - plainText: The data to be encrypted.
    ///   - publicKey: The RSA public key for encryption.
    /// - Returns: The encrypted data.
    /// - Throws: An error if encryption fails.
    func encryptRSA(_ plainText: Data, publicKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, plainText as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        return encryptedData
    }
    
    // MARK: - RSA Decryption
    
    /// Decrypts the provided encrypted data using the given RSA private key.
    ///
    /// - Parameters:
    ///   - encryptedData: The data to be decrypted.
    ///   - privateKey: The RSA private key for decryption.
    /// - Returns: The decrypted data.
    /// - Throws: An error if decryption fails.
    func decryptRSA(_ encryptedData: Data, privateKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionPKCS1, encryptedData as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        return decryptedData
    }
    
    // MARK: - RSA Signature
    
    /// Creates a digital signature for the provided data using the given RSA private key.
    ///
    /// - Parameters:
    ///   - data: The data to be signed.
    ///   - privateKey: The RSA private key for signing.
    /// - Returns: The digital signature.
    /// - Throws: An error if signature creation fails.
    func signData(_ data: Data, privateKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        
        guard let signature = SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA256, data as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        return signature
    }
    
    // MARK: - RSA Signature Verification
    
    /// Verifies the digital signature for the provided data using the given RSA public key.
    ///
    /// - Parameters:
    ///   - data: The data that was signed.
    ///   - signature: The digital signature to be verified.
    ///   - publicKey: The RSA public key for verification.
    /// - Returns: A boolean indicating whether the signature is valid.
    func verifySignature(_ data: Data, signature: Data, publicKey: SecKey) -> Bool {
        var error: Unmanaged<CFError>?
        
        // SecKeyVerifySignature returns true for success, false for failure
        return SecKeyVerifySignature(
            publicKey,
            .rsaSignatureMessagePKCS1v15SHA256,
            data as CFData,
            signature as CFData,
            &error
        )
    }
}
