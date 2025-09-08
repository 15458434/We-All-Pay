//
//  MCPaymentExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData
import os

extension MCPayment {
    @objc var hasPayer: Bool {
        self.payingPerson != nil
    }
    
    @objc var peoplePresentOnThisPayment: Int {
        let logger = Logger(category: "MCPayment")
        let context = self.managedObjectContext!
        let request = MCPaymentPresence.fetchRequest()
        request.predicate = NSPredicate(format: "payment = %@ AND isPersonPresent = %@", self, NSNumber(value: true))
        do {
            let countInteger = try context.count(for: request)
            logger.debug("Counted \(countInteger) people present.")
            return countInteger
        } catch {
            logger.error("Error counting peoplePresent: \(error)")
            return NSNotFound
        }
    }
    
    @objc var averageAmountPeopleShouldHavePaidOnThisPayment: Double {
        let peoplePresentOnThisPayment: Double = Double(self.peoplePresentOnThisPayment)
        let result: Double = self.money!.doubleValue / peoplePresentOnThisPayment
        return result
    }
    
    @objc var fullDescriptionOfPayment: String {
        // Not unit tested, because of multiple languages.
        if self.descriptionOfPayment == nil {
            let result = NSLocalizedString("payment_view_no_full_description", value: "Something", comment: "A term that replaced the description of an a payment when no description is entered in the payment.")
            return result
        } else if self.categoryId!.intValue == 0 {
            return self.descriptionOfPayment!
        } else {
            let categoryName = CategoryPictureStoreController.shared.pictureObjects[Int(self.categoryId!.intValue)].categoryDescription
            let result = "\(categoryName!) \(self.descriptionOfPayment!)"
            return result
        }
    }
    
    @objc var moneyInMainCurrency: NSDecimalNumber {
        guard let exchangeRate = self.exchangeRate else {
            // When the payment is added to the event, the exhcange rate is not present yet on the payment. When the array of payments on the event is observed, the observation is made before the exchange rate is present. Hence in case the exchangeRate isn't present yet, zero is returned. At this point the payment doesn't have a payment value anyway.
            return NSDecimalNumber.zero
        }
        let moneyDecimal = self.money!.decimalValue
        let exchangeRateDecimal = exchangeRate.exchangeRate!.decimalValue
        let result = moneyDecimal * exchangeRateDecimal
        return NSDecimalNumber(decimal: result)
    }
}
