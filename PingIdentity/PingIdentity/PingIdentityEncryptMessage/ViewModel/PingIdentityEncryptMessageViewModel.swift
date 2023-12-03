//
//  PingIdentityEncryptMessageViewModel.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation

// Custom typealias for completion closure
typealias oncompletion = (_ success : Bool , _ error : String?) -> Void

// MARK: - PingIdentityEncryptMessageViewModel Class

class PingIdentityEncryptMessageViewModel{
    
    // MARK: - Data Sources
    
    var rsaKeyDataSource : PingIdentityRSAKeyModel?
    var payloadDataSource : PingIdentityPayLoadModel?
    var secondRSAKeyDataSource : PingIdentitySecondRSAKeyModel?
    
    // MARK: - Generate RSA Key Pair
    
    /// Generates an RSA key pair and saves the private key to the keychain.
    ///
    /// - Parameter oncompletion: The completion closure indicating the success or failure of the operation.
    func generateRSAKeyPair(oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0){
            do {
                // Generate RSA key pair
                let (privateKey, publicKey) = try  RSAHandler.shared.generateRSAKeyPair()
                
                // Save private key to the keychain
                try PingIdentityKeyChainHandler.shared.saveKeyToKeychain(key: privateKey, identifier: StringConstants.KeyChainKey.Privatekey)
                
                // Update the data source with the RSA key pair
                self.rsaKeyDataSource = PingIdentityRSAKeyModel(publicKey: publicKey, privateKey: privateKey)
                
                // Notify completion with success
                oncompletion(true , nil)
            }catch let error {
                // Notify completion with error description
                print(error.localizedDescription)
                oncompletion(false , error.localizedDescription)
            }
        }
    }
    
    // MARK: - Encrypt Text Message
    
    /// Encrypts the input text using the provided RSA public key.
    ///
    /// - Parameters:
    ///   - inputText: The text to be encrypted.
    ///   - publicKey: The RSA public key used for encryption.
    ///   - oncompletion: The completion closure indicating the success or failure of the operation.
    func encryptTextMessage(inputText : String ,publicKey : SecKey , oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                // Encrypt the input text using the RSA public key
                let encryptedData = try  RSAHandler.shared.encryptRSA(Data((inputText).utf8), publicKey: publicKey)
                
                // Update the data source with the encrypted data
                self.payloadDataSource = PingIdentityPayLoadModel(encryptedData: encryptedData)
                
                // Notify completion with success
                oncompletion(true , nil)
            }catch let error {
                // Notify completion with error description
                oncompletion(false , error.localizedDescription)
            }
        }
    }
    
    // MARK: - Generate Second RSA Key Pair
    
    /// Generates a second set of RSA key pair and saves the second public key to the keychain.
    ///
    /// - Parameters:
    ///   - encryptedData: The encrypted data used during key pair generation.
    ///   - oncompletion: The completion closure indicating the success or failure of the operation.
    func generateSecondRSAKeyPair(encryptedData : Data , oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                // Generate second set of RSA key pair
                let (secondPrivateKey, secondPublicKey) = try  RSAHandler.shared.generateRSAKeyPair()
                
                // Save the second public key to the keychain
                try PingIdentityKeyChainHandler.shared.saveKeyToKeychain(key: secondPublicKey, identifier: StringConstants.KeyChainKey.secondPublicKey)
                
                // Update the data source with the second RSA key pair
                self.secondRSAKeyDataSource = PingIdentitySecondRSAKeyModel(publicKey: secondPublicKey, privateKey: secondPrivateKey)
                
                // Notify completion with success
                oncompletion(true , nil)
            }catch let error {
                // Notify completion with error description
                oncompletion(false , error.localizedDescription)
            }
        }
    }
    
    // MARK: - Sign Data
    
    /// Signs the encrypted data using the provided second RSA private key.
    ///
    /// - Parameters:
    ///   - encryptedData: The encrypted data to be signed.
    ///   - secondPrivateKey: The second RSA private key used for signing.
    ///   - oncompletion: The completion closure indicating the success or failure of the operation.
    func signedData(encryptedData : Data , secondPrivateKey : SecKey , oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                // Sign the encrypted data using the second RSA private key
                let signature = try  RSAHandler.shared.signData(encryptedData, privateKey: secondPrivateKey)
                
                // Update the data source with the signature
                self.payloadDataSource = PingIdentityPayLoadModel(signature: signature)
                
                // Notify completion with success
                oncompletion(true , nil)
            }catch let error {
                // Notify completion with error description
                oncompletion(false , error.localizedDescription)
            }
        }
    }
}
