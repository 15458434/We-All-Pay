//
//  PaymentTableViewHeaderFooterView.swift
//  We all pay
//
//  Created by Mark Cornelisse on 21/11/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPaymentTableViewHeaderFooterView) final class PaymentTableViewHeaderFooterView: UITableViewHeaderFooterView {
    @objc private weak var model: PaymentModel!
    
    @IBOutlet weak var payerNameField: UITextField!
    var payerTextInputPicker: PayerTextInputPicker!
    @IBOutlet weak var itemView: UITextField!
    var itemViewDelegate: DescriptionOfPaymentTextInputValidator!
    @IBOutlet weak var paidView: UITextField!
    var paidViewDelegate: MoneyTextInputValidator!
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var payerPicture: UIImageView!
    @IBOutlet weak var categoryView: UIImageView!
    
    @IBOutlet weak var bannerContainerView: UIView!
    
    private var payingPersonObservation: NSKeyValueObservation!
    private var descriptionOfPaymentObservation: NSKeyValueObservation!
    private var moneyObservation:NSKeyValueObservation!
    private var categoryIdObservation: NSKeyValueObservation!
    private var currencyObservation: NSKeyValueObservation!
    
    @objc(prepareForUseWithPaymentModel:) func prepareForUse(with paymentModel: PaymentModel) {
        func createKVO() {
            self.payingPersonObservation = self.observe(\.model!.payment!.payingPerson, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? MCPerson else {
                    mySelf.payerNameField.text = nil
                    mySelf.payerPicture.image = nil
                    return
                }
                
                mySelf.payerNameField.text = newValue.getFullName()
                mySelf.payerPicture.image = newValue.picture
            })
            self.descriptionOfPaymentObservation = self.observe(\.model!.payment!.descriptionOfPayment, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? String else {
                    return
                }
                
                mySelf.itemView.text = newValue
            })
            self.moneyObservation = self.observe(\.model!.payment!.money, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? NSNumber else {
                    mySelf.paidView.text = nil
                    return
                }
                
                mySelf.paidView.text = mySelf.model.currencyFormatter.string(for: newValue)
            })
            self.categoryIdObservation = self.observe(\.model!.payment!.categoryId, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? NSNumber else {
                    return
                }
                
                let categoryId = newValue.intValue
                let categoryObject = CategoryPictureStoreController.shared.pictureObjects[categoryId]
                if categoryId > 0 {
                    mySelf.categoryView.image = categoryObject.largePicture
                    mySelf.categoryButton.setTitle(categoryObject.categoryDescription, for: .normal)
                } else {
                    mySelf.categoryView.image = nil
                    let title = NSLocalizedString("Select Category", comment: "Text of the payment category selection button")
                    mySelf.categoryButton.setTitle(title, for: .normal)
                }
                
                mySelf.categoryButton.sizeToFit()
            })
            self.currencyObservation = self.observe(\.model!.payment!.currency, options: [.new], changeHandler: { mySelf, change in
                guard (change.newValue as? MCCurrency) != nil else {
                    return
                }
                
                mySelf.paidView.text = mySelf.model.currencyFormatter.string(for: mySelf.model.payment.money)
            })
        }
        func setupInputHandlers() {
            payerTextInputPicker = PayerTextInputPicker(with: model, and: payerNameField)
            itemViewDelegate = DescriptionOfPaymentTextInputValidator(with: model, and: itemView)
            paidViewDelegate = MoneyTextInputValidator(with: model, and: paidView)
        }
        
        self.model = paymentModel
        createKVO()
        setupInputHandlers()
    }
    
    // MARK: UITableViewHeaderFooterView
    
    override func prepareForReuse() {
        payingPersonObservation = nil
        descriptionOfPaymentObservation = nil
        moneyObservation = nil
        categoryIdObservation = nil
        currencyObservation = nil
        self.model = nil
        super.prepareForReuse()
    }
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
