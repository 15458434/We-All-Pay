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
            fatalError("Exchange Rate needs to be present.")
        }
        let moneyDecimal = self.money!.decimalValue
        let exchangeRateDecimal = exchangeRate.exchangeRate!.decimalValue
        let result = moneyDecimal * exchangeRateDecimal
        return NSDecimalNumber(decimal: result)
    }
}
