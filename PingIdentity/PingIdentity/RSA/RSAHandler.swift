//
//  RSAHandler.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation

final class RSAHandler{
    
    static let shared = RSAHandler()
    private init(){}
    
    // MARK: - RSA Key Pair Generation
    
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
    
    func encryptRSA(_ plainText: Data, publicKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, plainText as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        return encryptedData
    }
    
    // MARK: - RSA Decryption
    
    func decryptRSA(_ encryptedData: Data, privateKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionPKCS1, encryptedData as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        return decryptedData
    }
    
    // MARK: - RSA Signature
    
    func signData(_ data: Data, privateKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        
        guard let signature = SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA256, data as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        return signature
    }
    
    // MARK: - RSA Signature Verification
    
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
