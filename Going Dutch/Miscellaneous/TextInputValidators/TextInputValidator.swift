//
//  TextInputValidator.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCTextInputValidator) @objcMembers class TextInputValidator: NSObject, UITextFieldDelegate {
    private(set) weak var textField: UITextField!
    
    @objc(initWithTextField:) init(with textField: UITextField) {
        self.textField = textField
        super.init()
        self.textField.delegate = self
    }
    
    @objc(validateText:) func validate(text: String) -> Bool {
        return true
    }
    
    // MARK: UITextFieldDelegate
    
    // MARK: NSObject
}
