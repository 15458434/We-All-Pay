//
//  DescriptionOfPaymentTextInputValidator.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCDescriptionOfPaymentTextInputValidator) @objcMembers final class DescriptionOfPaymentTextInputValidator: TextInputValidator {
    private(set) weak var model: PaymentModel!
    private var changedText: String!
    
    @objc(initWithModel:andTextField:) init(with model: PaymentModel, and textField: UITextField) {
        self.model = model
        super.init(with: textField)
    }
    
    // MARK: TextInputValidator
    
    // MARK: UITextFieldDeletage
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        model.beginUpdates()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "")
        changedText = currentText.replacingCharacters(in: Range(range, in: currentText)!, with: string)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        model.update(descriptionOfPayment: changedText)
        model.endUpdates()
    }
    
    // MARK: NSObject
}
