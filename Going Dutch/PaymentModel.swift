//
//  PaymentModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 31/10/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPaymentModel) @objcMembers class PaymentModel: NSObject {
    private(set) var payment: MCPayment!
    private(set) var currencyFormatter: CurrencyFormatter!
    
    @objc(prepareForUseWithPayment:) func prepareForUse(with payment: MCPayment) {
        self.payment = payment
        currencyFormatter = CurrencyFormatter(currencyCode: payment.currency.code)
    }
    
    func beginUpdates() {
        payment.managedObjectContext!.undoManager!.beginUndoGrouping()
    }
    
    @objc(updateMoney:) func update(money: NSNumber) {
        payment.money = money
        payment.recalculateAveragePeopleOweAndStore()
    }
    
    func endUpdates() {
        payment.managedObjectContext!.undoManager!.endUndoGrouping()
    }
    
    // MARK: NSObject
}
