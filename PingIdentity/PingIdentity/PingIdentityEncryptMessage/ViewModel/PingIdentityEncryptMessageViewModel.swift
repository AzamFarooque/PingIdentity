//
//  PingIdentityEncryptMessageViewModel.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation

typealias oncompletion = (_ success : Bool , _ error : String?) -> Void

class PingIdentityEncryptMessageViewModel{
    
    var rsaKeyDataSource : PingIdentityRSAKeyModel?
    var payloadDataSource : PingIdentityPayLoadModel?
    var secondRSAKeyDataSource : PingIdentitySecondRSAKeyModel?
    
    
    func generateRSAKeyPair(oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0){
            do {
                let (privateKey, publicKey) = try  RSAHandler.shared.generateRSAKeyPair()
                try PingIdentityKeyChainHandler.shared.saveKeyToKeychain(key: privateKey, identifier: StringConstants.KeyChainKey.Privatekey)
                self.rsaKeyDataSource = PingIdentityRSAKeyModel(publicKey: publicKey, privateKey: privateKey)
                oncompletion(true , nil)
            }catch let error {
                oncompletion(false , error.localizedDescription)
            }
        }
    }
    
    func encryptTextMessage(inputText : String ,publicKey : SecKey , oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                let encryptedData = try  RSAHandler.shared.encryptRSA(Data((inputText).utf8), publicKey: publicKey)
                self.payloadDataSource = PingIdentityPayLoadModel(encryptedData: encryptedData)
                oncompletion(true , nil)
            }catch let error {
                oncompletion(false , error.localizedDescription)
            }
        }
    }
    
    func generateSecondRSAKeyPair(encryptedData : Data , oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                let (secondPrivateKey, secondPublicKey) = try  RSAHandler.shared.generateRSAKeyPair()
                try PingIdentityKeyChainHandler.shared.saveKeyToKeychain(key: secondPublicKey, identifier: StringConstants.KeyChainKey.secondPublicKey)
                self.secondRSAKeyDataSource = PingIdentitySecondRSAKeyModel(publicKey: secondPublicKey, privateKey: secondPrivateKey)
                oncompletion(true , nil)
            }catch let error {
                oncompletion(false , error.localizedDescription)
            }
        }
    }
    
    func signedData(encryptedData : Data , secondPrivateKey : SecKey , oncompletion : @escaping oncompletion){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            do {
                let signature = try  RSAHandler.shared.signData(encryptedData, privateKey: secondPrivateKey)
                self.payloadDataSource = PingIdentityPayLoadModel(signature: signature)
                oncompletion(true , nil)
            }catch let error {
                oncompletion(false , error.localizedDescription)
            }
        }
    }
  
}
