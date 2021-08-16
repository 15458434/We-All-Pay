//
//  NameTextInputValidator.swift
//  We all pay
//
//  Created by Mark Cornelisse on 07/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCNameTextInputValidator) @objcMembers final class NameTextInputValidator: TextInputValidator {
    @objc(MCNameTextInputValidatorConfig) enum Config: Int {
        case firstName
        case familyName
    }
    private(set) weak var model: PersonModel!
    let config: Config
    
    @objc(initWithModel:andTextField:andConfig:) init(with model: PersonModel, and textField: UITextField, and config: Config) {
        self.model = model
        self.config = config
        super.init(with: textField)
    }
    
    // MARK: TextInputValidator
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        model.beginUpdates()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        func updateModel() {
            switch config {
            case .firstName:
                model.update(firstName: textField.text)
            case .familyName:
                model.update(familyName: textField.text)
            }
        }
        
        func restoreTextField() {
            switch config {
            case .firstName:
                textField.text = model.person.firstName
            case .familyName:
                textField.text = model.person.lastName
            }
        }
        
        switch reason {
        case .committed:
            updateModel()
        case .cancelled:
            restoreTextField()
        @unknown default:
            fatalError("EmailTextInputValidator invalid reason")
        }
        model.endUpdates()
    }
    
    // MARK: NSObject
}
