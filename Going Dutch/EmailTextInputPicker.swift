//
//  EmailTextInputPicker.swift
//  We all pay
//
//  Created by Mark Cornelisse on 07/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCEmailTextInputPicker) @objcMembers final class EmailTextInputPicker: NSObject, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    private(set) weak var textField: UITextField!
    private(set) weak var model: PersonModel!
    
    private lazy var emailAddresses: [MCEmailAddress] = {
        return model.emailaddresses
    }()
    
    @objc(initWithTextField:andModel:) init(with textField: UITextField, and model: PersonModel) {
        self.textField = textField
        self.model = model
        super.init()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        model.beginUpdates()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        model.endUpdates()
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let emailAddress = emailAddresses[row]
        return emailAddress.emailAddress
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickedEmailAddress = emailAddresses[row]
        model.update(default: pickedEmailAddress)
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return emailAddresses.count
    }
    
    // MARK: NSObject
}
