//
//  Example.swift
//  PingIdentity
//
//  Created by Farooque Azam on 30/11/23.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
  
extension ViewController : UITextFieldDelegate{
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
