//
//  PingIdentitySecondRSAKeyModel.swift
//  PingIdentity
//
//  Created by Farooque Azam on 03/12/23.
//

import Foundation


// MARK: - Second RSA Key Model

/// Represents a model for storing a second pair of RSA keys (public and private).
struct PingIdentitySecondRSAKeyModel  {
    let publicKey: SecKey // The public key used for verifying
    let privateKey: SecKey // The private key used for signing
}
