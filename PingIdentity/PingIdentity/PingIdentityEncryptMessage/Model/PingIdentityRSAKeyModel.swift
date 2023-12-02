//
//  PingIdentityRSAKeyModel.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation

struct PingIdentityRSAKeyModel {
    let publicKey: SecKey
    let privateKey: SecKey
}

struct PingIdentityPayLoadModel {
    var signature : Data?
    var encryptedData : Data?
}

struct PingIdentitySecondRSAKeyModel  {
    let publicKey: SecKey
    let privateKey: SecKey
}
