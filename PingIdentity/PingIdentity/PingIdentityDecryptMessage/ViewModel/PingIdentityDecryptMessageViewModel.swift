//
//  PingIdentityDecryptMessageViewModel.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation

// MARK: - PingIdentityDecryptMessageViewModel Class

class PingIdentityDecryptMessageViewModel{
    
    // MARK: - Data Sources
    
    var decryptMessageDataSource : PingIdentityDecryptMessage?
    
    
    // MARK: - Verifying Signature
    
    /// Verifies the signature of the encrypted message using the stored public key.
    ///
    /// - Parameters:
    ///   - payload: The payload containing the encrypted message and its signature.
    ///   - oncompletion: A completion handler indicating the success or failure of the verification.
    func verifySignature(payload : [String : Any] , oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            let encryptedString = payload[StringConstants.JSONKey.EncryptedString]
            let signature = payload[StringConstants.JSONKey.Signature]
            if let encrpt = encryptedString , let sig = signature {
                do{
                    // Verify the signature using the stored public key
                    let secondPublicKey = try PingIdentityKeyChainHandler.shared.getKeyFromKeychain(identifier: StringConstants.KeyChainKey.secondPublicKey)
                    let isSignatureValid = RSAHandler.shared.verifySignature(encrpt as! Data, signature: sig as! Data, publicKey: secondPublicKey)
                    if isSignatureValid{
                        oncompletion(true , nil)
                    }else{
                        oncompletion(false , nil)
                    }
                }catch let error {
                    oncompletion(false , error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Decrypting Message
    
    /// Decrypts the encrypted message using the stored private key.
    ///
    /// - Parameters:
    ///   - encrpt: The encrypted data to be decrypted.
    ///   - oncompletion: A completion handler indicating the success or failure of the decryption.
    func decryptMessage(encrpt : Data , oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                // Decrypt the encrypted data using the stored private key
                let privateKey = try PingIdentityKeyChainHandler.shared.getKeyFromKeychain(identifier: StringConstants.KeyChainKey.Privatekey)
                let decryptedData = try RSAHandler.shared.decryptRSA(encrpt , privateKey: privateKey)
                
                // Convert decrypted data to a UTF-8 encoded string
                let decryptedText = String(data: decryptedData, encoding: .utf8) ?? "Decryption failed"
                self.decryptMessageDataSource = PingIdentityDecryptMessage(decryptMessage: decryptedText)
                oncompletion(true , nil)
            }catch let error {
                oncompletion(false , error.localizedDescription)
            }
        }
    }
}
