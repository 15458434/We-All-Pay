//
//  EmailTextInputValidator.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCEmailTextInputValidator) @objcMembers final class EmailTextInputValidator: TextInputValidator {
    private(set) weak var model: PersonModel!
    
    @objc(initWithTextField:andModel:) init(with textField: UITextField, and model: PersonModel) {
        self.model = model
        super.init(with: textField)
    }

    // MARK: TextInputValidator
    
    override func validate(text: String) -> Bool {
        return MCTools.isStringAnEmailAddress(text)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        model.beginUpdates()
        if #available(iOS 13.0, *) {
            textField.textColor = .label
        } else {
            textField.textColor = .darkText
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch reason {
        case .committed:
            if validate(text: textField.text ?? "") {
                model.update(defaultEmailAddress: textField.text!)
                if #available(iOS 13.0, *) {
                    textField.textColor = .label
                } else {
                    textField.textColor = .darkText
                }
            } else {
                textField.textColor = .red
            }
        case .cancelled:
            if model.person.emailAddress!.count >= 1 {
                textField.text = model.person.defaultEmailAddress()
            } else {
                textField.text = nil
            }
        @unknown default:
            fatalError("EmailTextInputValidator invalid reason")
        }
        model.endUpdates()
    }
    
    // MARK: NSObject
}
