//
//  PayerTextInputPicker.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

@objc(MCPayerTextInputPicker) @objcMembers final class PayerTextInputPicker: NSObject, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    private enum SelectablePeoplePresent {
        case none(String)
        case person(MCPerson)
    }
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
            if let payingPerson = model.payment.payingPerson, let index = self.selectableFromPeoplePresent.firstIndex(where: { selectable in
                switch selectable {
                case .person(let person):
                    return person == payingPerson
                case .none(_):
                    return false
                }
            }) {
                self.pickerView.selectedRow(inComponent: index)
            } else {
                let nextPayer = model.suggestedNextPayer!
                let index = self.selectableFromPeoplePresent.firstIndex(where: { selectable in
                    switch selectable {
                    case .person(let person):
                        return person == nextPayer
                    case .none(_):
                        return false
                    }
                })!
                self.pickerView.selectedRow(inComponent: index)
            }
        })
    }
    
    private lazy var selectableFromPeoplePresent: [SelectablePeoplePresent] = {
        var selectablePeople = model.arrayOfPeoplePresent.map { person in
            SelectablePeoplePresent.person(person)
        }
        let noneString = "-- \(NSLocalizedString("picker_option_none", value: "none", comment: "An string that indicates that no person is selected in the select payer picker")) --"
        selectablePeople.insert(.none(noneString), at: 0)
        return selectablePeople
    }()
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectableFromPeoplePresent.count
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let selectable = selectableFromPeoplePresent[row]
        switch selectable {
        case .person(let person):
            return person.getFullName()
        case .none(let stringValue):
            return stringValue
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        func sendToCrashLytics() {
            let arrayOfPeoplePresentAsArrayOfDictionaries = selectableFromPeoplePresent.dropFirst().map { selectable -> [String: Any] in
                switch selectable {
                case .person(let person):
                    let dictionary = person.dictionaryWithValues(forKeys: ["defaultEmailAddress", "firstName", "lastName", "totalSumPaid", "uniquePersonId"])
                    return dictionary
                default:
                    // The none element should be removed from the array.
                    fatalError()
                }
            }
            Crashlytics.crashlytics().log("arrayOfPeoplePresent: \(arrayOfPeoplePresentAsArrayOfDictionaries)")
            Crashlytics.crashlytics().log("didSelected row: \(row), inComponent: \(component)")
        }
        
        sendToCrashLytics()
        
        switch selectableFromPeoplePresent[row] {
        case .person(let selectedPayingPerson):
            model.update(payingPerson: selectedPayingPerson)
        default:
            // The none element should be removed from the array.
            model.update(payingPerson: nil)
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard model!.payment!.onWhichBill!.peoplePresent!.count > 0 else {
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        model.beginUpdates()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if model.payment.payingPerson == nil {
            let index = pickerView.selectedRow(inComponent: 0)
            let selectable = selectableFromPeoplePresent[index];
            switch selectable {
            case .person(let selectedPerson):
                model.update(payingPerson: selectedPerson)
            case .none(_):
                model.update(payingPerson: nil)
            }
            
        }
        model.endUpdates()
    }
    
    // MARK: NSObject
}
