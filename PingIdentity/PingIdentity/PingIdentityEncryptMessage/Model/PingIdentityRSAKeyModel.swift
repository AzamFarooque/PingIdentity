//
//  PingIdentityRSAKeyModel.swift
//  PingIdentity
//
//  Created by Farooque Azam on 02/12/23.
//

import Foundation

// MARK: - RSA Key Model

/// Represents a model for storing a pair of RSA keys (public and private).
struct PingIdentityRSAKeyModel {
    let publicKey: SecKey // The public key used for encryption or verification
    let privateKey: SecKey // The private key used for decryption or signing
}

// MARK: - Payload Model

/// Represents a model for storing payload information including signature and encrypted data.
struct PingIdentityPayLoadModel {
    var signature : Data? // The signature data for signed content
    var encryptedData : Data? // The encrypted data content
}

// MARK: - Second RSA Key Model

/// Represents a model for storing a second pair of RSA keys (public and private).
struct PingIdentitySecondRSAKeyModel  {
    let publicKey: SecKey // The public key used for verifying
    let privateKey: SecKey // The private key used for signing
}
