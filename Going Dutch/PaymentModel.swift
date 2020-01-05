//
//  PaymentModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 31/10/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPaymentModel) @objcMembers public class PaymentModel: NSObject {
    @objc public private(set) dynamic var payment: MCPayment!
    private(set) var currencyFormatter: CurrencyFormatter!
    private var changeHandler: ((_ payment: MCPayment) -> ())!
    
    @objc(prepareForUseWithPayment:andChangeHandler:) func prepareForUse(with payment: MCPayment, and changeHandler:@escaping ((_ payment: MCPayment) -> ())) {
        self.payment = payment
        currencyFormatter = CurrencyFormatter(currencyCode: payment.currency.code)
        
        self.changeHandler = changeHandler
    }
    
    func beginUpdates() {
        payment.managedObjectContext!.undoManager!.beginUndoGrouping()
    }
    
    @objc(updateCategoryWithObject:) func update(categoryObject: CategoryPictureObject) {
        payment.categoryId = NSNumber(value: categoryObject.categoryId)
        let nu = Date()
        payment.dateModified = nu
        payment.onWhichBill.dateModified = nu
        changeHandler(payment)
    }
    
    @objc(updateDescriptionOfPayment:) func update(descriptionOfPayment: String) {
        payment.descriptionOfPayment = descriptionOfPayment
        let nu = Date()
        payment.dateModified = nu
        payment.onWhichBill.dateModified = nu
        changeHandler(payment)
    }
    
    @objc(updateMoney:) func update(money: NSNumber) {
        payment.money = money
        payment.recalculateAveragePeopleOweAndStore()
        changeHandler(payment)
    }
    
    func endUpdates() {
        payment.managedObjectContext!.undoManager!.endUndoGrouping()
    }
    
    // MARK: NSObject
}
