//
//  PayerTextInputPicker.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPayerTextInputPicker) @objcMembers class PayerTextInputPicker: NSObject, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    private(set) var keyboardWillShowObserver: NSObjectProtocol!
    private(set) weak var model: PaymentModel!
    private(set) weak var textField: UITextField!
    private(set) var pickerView: UIPickerView!
    
    init(with model: PaymentModel, and textField: UITextField) {
        super.init()
        self.model = model
        self.textField = textField
        self.textField.delegate = self
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        textField.inputView = pickerView
        keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UITextField.keyboardWillShowNotification, object: textField, queue: nil, using: { [unowned self] (notification) in
            if let index = self.arrayOfPeoplePresent.firstIndex(of: model.payment.payingPerson) {
                self.pickerView.selectedRow(inComponent: index)
            } else {
                let nextPayer = model.suggestedNextPayer!
                let index = self.arrayOfPeoplePresent.firstIndex(of: nextPayer)!
                self.pickerView.selectedRow(inComponent: index)
            }
        })
    }
    
    private lazy var arrayOfPeoplePresent: [MCPerson] = {
        return model.arrayOfPeoplePresent
    }()
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return model.payment.onWhichBill.peoplePresent.count
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayOfPeoplePresent[row].getFullName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let payingPerson = arrayOfPeoplePresent[row]
        model.update(payingPerson: payingPerson)
        
        textField.text = payingPerson.getFullName
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard model.payment.onWhichBill.peoplePresent.count > 0 else {
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        model.beginUpdates()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        model.endUpdates()
    }
    
    // MARK: NSObject
}
