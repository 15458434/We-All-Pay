//
//  MCPersonExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 15/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData
import os

extension MCPerson  {
    @objc(name) var name: String {
        if let firstName {
            return firstName
        } else if let lastName {
            return lastName
        } else if let defaultEmailAddress = self.defaultEmailAddress {
            return defaultEmailAddress
        } else {
            return "..."
        }
    }

    @objc(fullName) var fullName: String {
        switch (firstName, lastName, defaultEmailAddress) {
        case let (f, l, _) where f != nil && l != nil:
            return "\(f!) \(l!)"
        case let (f, l, _) where f != nil && l == nil:
            return f!
        case let (f, l, _) where f == nil && l != nil:
            return l!
        case let (f, l, d) where f == nil && l == nil && d != nil:
            return d!
        default:
            return "...";
        }
    }
    
    @objc(hasEmailAddress) var hasEmailAddress: Bool {
        guard let emailAddress else {
            return false
        }
        if emailAddress.isEmpty {
            return false
        } else {
            let amountOfDeleteEmailAddresses = self.emailAddress!.reduce(0) { partialResult, emailAddress in
                if emailAddress.isDeleted {
                    return partialResult + 1
                } else {
                    return partialResult
                }
            }
            return amountOfDeleteEmailAddresses != self.emailAddress!.count
        }
    }
    
    @objc(defaultEmailAddress) var defaultEmailAddress: String? {
        defaultEmailAddressObject?.emailAddress
    }
    
    @objc(defaultEmailAddressObject) var defaultEmailAddressObject: MCEmailAddress? {
        let request = MCEmailAddress.fetchRequest()
        request.predicate = NSPredicate(format: "owner = %@ AND selected = YES", self)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCEmailAddress.uniqueEmailId, ascending: true)]
        let defaultEmailAddresses = try! self.managedObjectContext!.fetch(request)
        if defaultEmailAddresses.isEmpty {
            return nil
        }
        return defaultEmailAddresses.first
    }
    
    @objc(totalSumPaid) var totalSumPaid: NSNumber? {
        let result: NSDecimalNumber? = self.payments?
            .reduce(NSDecimalNumber.zero) { (partialResult, payment) -> NSDecimalNumber in
                let partialValue = partialResult.decimalValue
                let value = payment.moneyInMainCurrency().decimalValue
                let resultValue = partialValue + value
                return NSDecimalNumber(decimal: resultValue)
            }
        return result
    }
    
    @objc(hasPersonMadePaymentWithInvalidExchangeRates) var hasPersonMadePaymentWithInvalidExchangeRates: Bool {
        let logger = Logger(category: "MCPerson")
        guard let managedObjectContext = self.managedObjectContext else {
            fatalError("self.managedObjectContext should be present.")
        }
        let request = MCExchangeRate.fetchRequest()
        request.predicate = NSPredicate(format: "payment.payingPerson = %@ AND status != 0", self)
        do {
            let amountOfInvalidExchangeRates = try managedObjectContext .count(for: request)
            logger.debug("amountOfInvalidExchangeRates on \(self, privacy: .private(mask: .hash)) is \(amountOfInvalidExchangeRates, privacy: .public) ")
            return (amountOfInvalidExchangeRates > 0)
        } catch {
            logger.error("amountOfInvalidExchangeRates on \(self, privacy: .private(mask: .hash)) caused an error: \(error)")
            return false
        }
    }

    @objc var picture: UIImage? {
        get {
            if let pictureData = self.pictureData {
                return UIImage(data: pictureData)
            } else {
                return nil
            }
        }
        set {
            if let newValue {
                self.pictureData = newValue.pngData()
            } else {
                let newImage = UIImage(named: "No picture Image 3 - picture")!
                self.pictureData = newImage.pngData()
            }
        }
    }
    
    @objc var thumbnail: UIImage? {
        get {
            if let thumbnailData = self.thumbnailData {
                return UIImage(data: thumbnailData)
            } else {
                return nil
            }
        }
        set {
            if let newValue {
                self.thumbnailData = newValue.pngData()
            } else {
                let newImage = UIImage(named: "No picture Image 3 - thumbnail")!
                self.thumbnailData = newImage.pngData()
            }
        }
    }
    
    // MARK: NSManagedObject
    
    // MARK: NSObject
}
