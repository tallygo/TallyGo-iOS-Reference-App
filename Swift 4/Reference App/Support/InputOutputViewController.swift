//
//  InputOutputViewController.swift
//  Reference App
//
//  Created by David Deller on 5/1/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class InputOutputViewController: OutputViewController, UITextFieldDelegate {

    @IBOutlet weak var inputField: UITextField!
    
    // MARK: -
    
    @IBAction func goSubmit(_ sender: Any?) {
        clearOutput()
        
        if let input = inputField.text {
            handleInput(input)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        clearOutput()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        clearOutput()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        goSubmit(textField)
        return false
    }
    
    // MARK: -
    
    func handleInput(_ input: String) {
        // Subclass should override
    }

}
