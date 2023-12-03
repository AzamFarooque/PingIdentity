//
//  RSAError.swift
//  PingIdentity
//
//  Created by Farooque Azam on 03/12/23.
//

import Foundation

// Define a custom enumeration to represent RSA-related errors
public enum RSAError: Error {
    case keyGenerationFailed(error: CFError?)
    case encryptionFailed(error: CFError?)
    case decryptionFailed(error: CFError?)
    case signatureCreationFailed(error: CFError?)
}

// Extend the custom error enum to conform to the LocalizedError protocol
extension RSAError: LocalizedError {
    // Provide a localized description for each error case
    public var errorDescription: String? {
        switch self {
        case .keyGenerationFailed:
            return StringConstants.RSAErrorString.KeyPairGenerationFailedText
        case .encryptionFailed:
            return StringConstants.RSAErrorString.EncryptionFailed
        case .decryptionFailed:
            return StringConstants.RSAErrorString.DecryptionFailed
        case .signatureCreationFailed:
            return StringConstants.RSAErrorString.SignatureCreationFailed
        }
    }
}
