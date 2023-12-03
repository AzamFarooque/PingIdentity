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
