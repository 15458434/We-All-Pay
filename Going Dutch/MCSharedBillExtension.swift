//
//  MCSharedBillExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 30/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData
import CurrencyConverter

public extension MCSharedBill {
    @objc(updatePaymentForSupportWithPaymentPresence) func updatePaymentForSupportWithPaymentPresence() {
        // Always executed to maintain unit test compatibility.
        let currencyController = CurrencyController()
        let currencyModel = CurrencyModel(managedObjectContext: self.managedObjectContext!, currencyController: currencyController)
        let eventModel = EventModel(event: self, currencyModel: currencyModel)
        self.payments?
            .map({ $0 as! MCPayment })
            .map({ PaymentModel(with: $0, fromEventOf: eventModel) })
            .forEach({ $0.recalculateAveragePeopleOweAndStore() })
    }
    
    @objc(areTherePeople) var areTherePeople: Bool {
        let peoplePresent = peoplePresent as? Set<MCPerson>
        let result = !(peoplePresent?.isEmpty ?? false)
        return result
    }
    
    @objc(totalAmountOfPeoplePresent) var totalAmountOfPeoplePresent: UInt {
        UInt(self.peoplePresent?.count ?? 0)
    }
}
