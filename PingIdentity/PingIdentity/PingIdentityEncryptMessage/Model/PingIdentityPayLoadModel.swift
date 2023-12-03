//
//  PingIdentityPayLoadModel.swift
//  PingIdentity
//
//  Created by Farooque Azam on 03/12/23.
//

import Foundation

// MARK: - Payload Model

/// Represents a model for storing payload information including signature and encrypted data.
struct PingIdentityPayLoadModel {
    var signature : Data? // The signature data for signed content
    var encryptedData : Data? // The encrypted data content
}
