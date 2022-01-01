//
//  MCPaymentTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

final class MCPaymentTableViewCell: UITableViewCell {
    @objc private var payment: MCPayment!
    private var currencyFormatter: CurrencyFormatter!
    
    @IBOutlet var namePayerLabel: UILabel!
    @IBOutlet var whatPaidLabel: UILabel!
    @IBOutlet var moneyPaidLabel: UILabel!
    @IBOutlet var itemTypeImageView: UIImageView!
    
    private var payingPersonObservation: NSKeyValueObservation!
    private var descriptionOfPaymentObservation: NSKeyValueObservation!
    private var moneyObservation:NSKeyValueObservation!
    private var categoryIdObservation: NSKeyValueObservation!
    private var currencyObservation: NSKeyValueObservation!
    
    private func destroyKVO() {
        self.payingPersonObservation = nil
        self.descriptionOfPaymentObservation = nil
        self.moneyObservation = nil
        self.categoryIdObservation = nil
        self.currencyObservation = nil
    }
    
    @objc(updateWithPayment:) func update(with payment: MCPayment) {
        func createKVO() {
            self.payingPersonObservation = self.observe(\.payment.payingPerson, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? MCPerson else {
                    self.namePayerLabel.text = NSLocalizedString("label_no_person", value: "No one", comment: "A string to indicate no person is available on this payment")
                    return
                }
                
                self.namePayerLabel.text = newValue.getFullName()
            })
            self.descriptionOfPaymentObservation = self.observe(\.payment.descriptionOfPayment, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? String else {
                    mySelf.whatPaidLabel.text = NSLocalizedString("label_no_item_description", value: "Something", comment: "A string that is shown when the description of the item it not available.")
                    return
                }
                
                mySelf.whatPaidLabel.text = newValue
            })
            self.moneyObservation = self.observe(\.payment.money, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? NSNumber else {
                    mySelf.moneyPaidLabel.text = nil
                    return
                }
                
                
                mySelf.moneyPaidLabel.text = mySelf.currencyFormatter.string(for: newValue)
            })
            self.categoryIdObservation = self.observe(\.payment.categoryId, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? NSNumber else {
                    return
                }
                
                let categoryId = newValue.intValue
                let categoryObject = CategoryPictureStoreController.shared.pictureObjects[categoryId]
                if categoryId > 0 {
                    mySelf.itemTypeImageView.image = categoryObject.largePicture
                } else {
                    mySelf.itemTypeImageView.image = nil
                }
            })
            self.currencyObservation = self.observe(\.payment.currency, options: [.new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? MCCurrency else {
                    mySelf.moneyPaidLabel.text = nil
                    return
                }
                
                mySelf.currencyFormatter = CurrencyFormatter(currencyCode: newValue.code!)
                mySelf.moneyPaidLabel.text = mySelf.currencyFormatter.string(for: mySelf.payment.money)
            })
        }
        
        if self.payment != nil {
            reset()
        }
        self.payment = payment
        currencyFormatter = CurrencyFormatter(currencyCode: payment.currency!.code!)
        createKVO()
    }
    
    private func reset() {
        destroyKVO()
        self.payment = nil
        self.currencyFormatter = nil
    }
    
    // MARK: UITableViewCell
    
    override func prepareForReuse() {
        reset()
        
        super.prepareForReuse()
    }
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
