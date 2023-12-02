//
//  Example.swift
//  PingIdentity
//
//  Created by Farooque Azam on 30/11/23.
//

import Foundation
import UIKit

class PingIdentityEncryptMessageVC: UIViewController {
    // InputTextField IBOutlet
    @IBOutlet weak var inputTextField: UITextField!
    
    // MARK: - viewDidLoad Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextField.setLeftPaddingPoints(16)
    }
}

// TextField delegates method implementaion in extesnion
extension PingIdentityEncryptMessageVC : UITextFieldDelegate{
   
    // MARK: - Textfield ShouldReturn
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
