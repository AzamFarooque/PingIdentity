# PingIdentity

#Overview

This document provides instructions on using and understanding the Secure Messaging App. The app allows users to send secure and encrypted messages with the option to use biometric authentication for added security.

#Features

1. Text Entry and Encryption:

Users can enter text in the provided text edit field.
Upon pressing the "Send" button, the app performs the following operations:
Creates an RSA key pair (1024-bit size) for encrypting the entered text.
Encrypts the text using RSA encryption with PKCS padding.
Creates another RSA key pair for signing the encrypted text using SHA256 as the digest.
Attaches the signature to the payload.

2. Background Task and Local Push Notification:

Initiates a background task that sends a local push notification 15 seconds after the user closes the app and moves it to the background.
The push notification contains the encrypted text along with its signature.

3. Lock Screen Notification and Biometric Authentication:

The device receives the push notification even when the app is in the background and the phone is locked.
Tapping the lock screen notification opens the app and navigates to a new view controller.
The user is prompted with a biometric popup (based on LAContext) for authentication.
Biometric authentication is optional and can be disabled/enabled using a switch on the first page.

4. Label Notifications:

Throughout the process, labels on the screen acknowledge each step, such as "Keypair created," "String encrypted," "String signed," etc.

# How to Use

Text Entry:
Open the app and enter the desired text in the provided text edit field.

Send Secure Message:
Press the "Send" button to trigger the encryption, signing, and background task.

Biometric Authentication (Optional):
Use the switch on the first page to enable/disable biometric authentication.

Receiving and Decrypting:
Close the app and wait for 15 seconds to receive a local push notification.
Tap the lock screen notification to open the app and move to a new view controller.
If biometric authentication is enabled, approve the biometrics.
Labels on the screen acknowledge each step, such as "Signature verified," "String decrypted," etc.

#Dependencies

The app relies on the following technologies and libraries:

Swift Programming Language
RSA Encryption/Decryption
SHA256 for Digest
Local Push Notifications
LAContext for Biometric Authentication


#Setup

To run the app, follow these steps:

Clone the repository: git clone [https://github.com/AzamFarooque/PingIdentity]
Open the project in Xcode.
Build and run the app on a simulator or physical device.


#Contributors
[Farooque Azam]
