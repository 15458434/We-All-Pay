//
//  PaymentSpawningPool.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 21/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

@testable import We_all_pay;
@testable import CurrencyConverter;

import UIKit

final class PaymentSpawningPool: NSObject {
    let eventModel: EventModel
    
    init(eventModel: EventModel) {
        self.eventModel = eventModel
        super.init()
    }
    
    func createPayment(selectPayer: MCPerson?, selectCategory: CategoryPictureObject?, descriptionOfPayment: String?, selectCurrency: String?, money: NSNumber?) -> MCPayment {
        let newPayment = eventModel.addPayment()
        let paymentModel = PaymentModel(with: newPayment, fromEventOf: eventModel)
        paymentModel.update(payingPerson: selectPayer)
        if let selectCategory {
            paymentModel.update(categoryObject: selectCategory)
        }
        paymentModel.update(descriptionOfPayment: descriptionOfPayment)
        if let selectCurrency {
            paymentModel.update(currencyFromCode: selectCurrency)
        }
        paymentModel.update(money: money)
        return newPayment
    }
}
