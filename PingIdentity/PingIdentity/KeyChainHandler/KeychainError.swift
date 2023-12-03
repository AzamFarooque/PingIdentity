//
//  PingIdentityKeychainError.swift
//  PingIdentity
//
//  Created by Farooque Azam on 03/12/23.
//

import Foundation


// MARK: - KeychainError Enum

/// Enum to represent Keychain-related errors
enum KeychainError: Error {
    case keySaveError(status: OSStatus)
    case keyLoadError(status: OSStatus)
    case keyDeleteError(status: OSStatus)
}
