//
//  PingIdentityDecryptMessageViewModel.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation


class PingIdentityDecryptMessageViewModel{
    
    var decryptMessageDataSource : PingIdentityDecryptMessage?
    
    // MARK: - Verifying Signature
    
    func verifySignature(payload : [String : Any] , oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            let encryptedString = payload[StringConstants.JSONKey.EncryptedString]
            let signature = payload[StringConstants.JSONKey.Signature]
            if let encrpt = encryptedString , let sig = signature {
                do{
                    // Verify the signature using the public key
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
    
    func decryptMessage(encrpt : Data , oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                // Decrypt the encrypted data using the private key
                let privateKey = try PingIdentityKeyChainHandler.shared.getKeyFromKeychain(identifier: StringConstants.KeyChainKey.Privatekey)
                let decryptedData = try RSAHandler.shared.decryptRSA(encrpt , privateKey: privateKey)
                let decryptedText = String(data: decryptedData, encoding: .utf8) ?? "Decryption failed"
                self.decryptMessageDataSource = PingIdentityDecryptMessage(decryptMessage: decryptedText)
                oncompletion(true , nil)
            }catch let error {
                oncompletion(false , error.localizedDescription)
            }
        }
    }
}
