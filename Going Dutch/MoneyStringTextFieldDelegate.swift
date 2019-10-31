//
//  MoneyStringTextFieldDelegate.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/10/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objcMembers @objc(MCMoneyStringTextFieldDelegate) class MoneyStringTextFieldDelegate: NSObject, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField! {
        willSet {
            newValue.delegate = self
        }
    }
    @IBOutlet weak var model: PaymentModel!
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        model.beginUpdates()
        let money = model.payment.money
        textField.text = model.currencyFormatter.editingString(for: money!)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch reason {
        case .committed:
            if let number = model.currencyFormatter.doubleFromString(textField.text ?? "") {
                model.update(money: number)
                if #available(iOS 13.0, *) {
                    textField.textColor = .label
                } else {
                    textField.textColor = .darkText
                }
                var currencyString: String? = model.currencyFormatter.string(for: self.model.payment.money)
                if currencyString == "0" {
                    currencyString = nil
                }
                textField.text = currencyString
            } else {
                textField.textColor = .red
            }
        case .cancelled:
            if #available(iOS 13.0, *) {
                textField.textColor = .label
            } else {
                textField.textColor = .darkText
            }
        @unknown default:
            fatalError("Unknown value for DidEndEditingReason. Software needs update.")
        }
        model.endUpdates()
    }
    
    // MARK: NSObject
}
