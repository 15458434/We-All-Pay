//
//  CurrencyUpdateModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc protocol CurrencyUpdateModel {
    var currencyCode: String { get }
    func updateCurrency(with code: String, with completion: @escaping ((_ error: Error?) -> Void))
    var recentSelectedCurrencies: [MCCurrency] { get }
}

final class PaymentUpdateCurrencyModel: NSObject, CurrencyUpdateModel {
    let payment: MCPayment
    
    @objc init(with payment: MCPayment) {
        self.payment = payment
        super.init()
    }
    
    // MARK: CurrencyUpdateModel
    
    var currencyCode: String {
        return self.payment.currency!.code!
    }
    
    func updateCurrency(with code: String, with completion: @escaping ((Error?) -> Void)) {
        let mainThreadContext = WeAllPayStoreController.defaultStore.viewContext
        let newCurrency = MCCurrency(from: code, from: mainThreadContext)
        let oldCurrency = payment.currency
        payment.currency = newCurrency
        if oldCurrency?.sharedBill?.count == 0 && oldCurrency?.payment?.count == 0 {
            mainThreadContext.delete(oldCurrency!)
        }
        
        payment.setNewCurrencyAndAutomaticallyUpdateExchangeRate(newCurrency, withCompletionHandler: completion)
    }
    
    var recentSelectedCurrencies: [MCCurrency] {
        return payment.onWhichBill!.recentUsedForeignCurrencies(5) ?? [MCCurrency]()
    }
}
