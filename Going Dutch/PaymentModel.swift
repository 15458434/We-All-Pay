//
//  PaymentModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 31/10/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit
import os
import CurrencyConverter

import FirebaseCrashlytics

@objc(MCPaymentModel) @objcMembers public final class PaymentModel: NSObject, CurrencyUpdateModel {
    @objc private(set) var payment: MCPayment!
    private(set) var currencyFormatter: CurrencyFormatter!
    private(set) var eventModel: EventModel!
    @objc private(set) dynamic var error: NSError?
    private var currencyModel: CurrencyModel!
    let logger = Logger(category: "PaymentModel")
    
    @objc(initWithPayment:fromEventOfEventModel:) convenience init(with payment: MCPayment, fromEventOf eventModel: EventModel) {
        self.init()
        prepareForUse(with: payment, fromEventOf: eventModel)
    }

    @objc(prepareForUseWithPayment:fromEventOfEventModel:) func prepareForUse(with payment: MCPayment, fromEventOf eventModel: EventModel) {
        logger.trace(#function)
        func createPeoplePresenceController(for payment: MCPayment) {
            let request = MCPaymentPresence.fetchRequest()
            request.relationshipKeyPathsForPrefetching = [ "person", "payment", "payment.currency", "onWhichBill.mainCurrency", "payment.exchangeRate" ]
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPaymentPresence.dateCreated, ascending: false)]
            request.predicate = NSPredicate(format: "payment = %@", payment)
            
            peoplePresenceController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: payment.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            
        }
        
        // #971 - Logging to see what's going on exactly.
        let paymentDictionary = payment.dictionaryWithValues(forKeys: ["categoryId", "dateCreated", "dateModified", "descriptionOfPayment", "money", "moneyInMainCurrency", "uniquePaymentId", "managedObjectContext"])
        Crashlytics.crashlytics().log("prepareForUseWithPayment: \(paymentDictionary)")
        
        self.eventModel = eventModel
        self.payment = payment
        createPeoplePresenceController(for: payment)
        currencyFormatter = CurrencyFormatter(currencyCode: payment.currency!.code!)
        currencyModel = CurrencyModel(managedObjectContext: payment.managedObjectContext!, currencyController: CurrencyController())
    }
    
    private(set) var peoplePresenceController: NSFetchedResultsController<MCPaymentPresence>!
    
    var sortedPeoplePresent: [MCPerson] {
        eventModel.peoplePresentOnEventSortedOnFullName
    }
    
    var suggestedNextPayer: MCPerson? {
        let peoplePresentSorted = eventModel.peoplePresentOrderedByAmountPaid(inAscendingOrder: true)
        let result = peoplePresentSorted.first
        return result
    }
    
    func beginUpdates() {
        payment.managedObjectContext!.undoManager!.beginUndoGrouping()
    }
    
    @objc(paymentPresenceForPerson:withError:) func paymentPresence(for person: MCPerson) throws -> MCPaymentPresence {
        let logger = Logger(category: "PaymentModel")
        let request = MCPaymentPresence.fetchRequest()
        request.predicate = NSPredicate(format: "payment = %@ AND person = %@", payment, person)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPaymentPresence.averageOweFromPayment, ascending: true)]
        do {
            let results = try payment.managedObjectContext!.fetch(request)
            return results.first!
        } catch {
            logger.error("Something went wrong fetching MCPaymentPresence: \(error)")
            throw error
        }
    }
    
    @objc(updateCurrencyAndUpdateExchangeRate:withCompletionHandler:) func update(currency newCurrency: MCCurrency, andUpdateExchangeRateWith completionHandler: @escaping (_ error: (any Error)?) -> Void) {
        payment.currency = newCurrency
        payment.exchangeRate!.fromCurrency = newCurrency
        
        payment.exchangeRate!.status = MCExchangeRateStatus.fetching.rawValue as NSNumber
        // If equal just set the exchangeRate to a value of 1.
        let fetcher = WeAllPayStoreController.defaultStore.fetcher
        fetcher.exchangeRate(payment.exchangeRate!.fromCurrency!.code!, toCode: payment.exchangeRate!.toCurrency!.code!) { [weak self] fromCode, toCode, exchangeRate, error in
            guard error == nil else {
                completionHandler(error!)
                self?.payment.exchangeRate!.status = MCExchangeRateStatus.invalid.rawValue as NSNumber
                return
            }
            self?.payment.exchangeRate?.exchangeRate = exchangeRate
            self?.payment.exchangeRate!.status = MCExchangeRateStatus.valid.rawValue as NSNumber
        }
    }
    
    @objc(updatePayingPerson:) func update(payingPerson: MCPerson?) {
        if let payingPerson = payingPerson {
            payingPerson.addPaymentsObject(payment)
            payment.payingPerson = payingPerson
        } else {
            let personToBeRemoved = payment.payingPerson
            personToBeRemoved?.removePaymentsObject(payment)
            payment.payingPerson = nil
        }
        updateDateModified()
    }
    
    @objc(updateCategoryWithObject:) func update(categoryObject: CategoryPictureObject) {
        payment.categoryId = NSNumber(value: categoryObject.categoryId)
        updateDateModified()
    }
    
    @objc(updateDescriptionOfPayment:) func update(descriptionOfPayment: String?) {
        payment.descriptionOfPayment = descriptionOfPayment
        updateDateModified()
    }
    
    @objc(updateMoney:) func update(money: NSNumber?) {
        payment.money = money
        self.recalculateAveragePeopleOweAndStore()
    }
    
    @objc(updateCurrency:) func update(currency: Currency) {
        update(currencyFromCode: currency.code)
    }
    
    func update(currencyFromCode code: String) {
        currencyFormatter = CurrencyFormatter(currencyCode: code)
        let mainThreadContext = payment.managedObjectContext!
        let newCurrency = currencyModel.currency(from: code)
        let oldCurrency = payment.currency
        payment.currency = newCurrency
        if oldCurrency?.sharedBill?.count == 0 && oldCurrency?.payment?.count == 0 {
            mainThreadContext.delete(oldCurrency!)
        }
        
        update(currency: newCurrency) { [weak self] error in
            guard error == nil else {
                // TODO: Handle error
                self?.error = error! as NSError
                return
            }
        }
    }
    
    func update(person: MCPerson, to isPresent: Bool) throws {
        let personPresence = try paymentPresence(for: person)
        update(paymentPresence: personPresence, to: isPresent)
    }
    
    @objc(updatePaymentPresence:toIsPresent:) func update(paymentPresence: MCPaymentPresence, to isPresent: Bool) {
        // TODO: Make unit test.
        WeAllPayStoreController.defaultStore.beginUndoGroupWithoutRegistration()
        paymentPresence.isPersonPresent = isPresent as NSNumber
        self.recalculateAveragePeopleOweAndStore()
        WeAllPayStoreController.defaultStore.endUndoGroupWithoutRegistration()
    }
    
    func recalculateAveragePeopleOweAndStore() {
        let now = Date()
        let averagePayedByPeoplePresent = payment.averageAmountPeopleShouldHavePaidOnThisPayment
        payment.peopleSharingPayment?.forEach({ paymentPresence in
            if paymentPresence.isPersonPresent?.boolValue ?? false {
                paymentPresence.averageOweFromPayment = averagePayedByPeoplePresent as NSNumber
            } else {
                paymentPresence.averageOweFromPayment = 0 as NSNumber
            }
            paymentPresence.dateModified = now  
        })
        payment.dateModified = now
        payment.onWhichBill!.dateModified = now
    }
    
    @nonobjc private func updateDateModified() {
        let nu = Date()
        payment.dateModified = nu
        payment.onWhichBill!.dateModified = nu
    }
    
    func endUpdates() {
        let mutablePayment = payment.onWhichBill!.mutableSetValue(forKey: "payments")
        mutablePayment.add(payment!)
        payment.managedObjectContext!.undoManager!.endUndoGrouping()
    }
    
    // MARK: CurrencyUpdateModel
    
    var currencyCode: String {
        return self.payment.currency!.code!
    }
    
    func updateCurrency(with code: String, with completion: @escaping ((Error?) -> Void)) {
        let mainThreadContext = WeAllPayStoreController.defaultStore.viewContext
        let newCurrency = currencyModel.currency(from: code)
        let oldCurrency = payment.currency
        payment.currency = newCurrency
        if oldCurrency?.sharedBill?.count == 0 && oldCurrency?.payment?.count == 0 {
            mainThreadContext.delete(oldCurrency!)
        }
        
        update(currency: newCurrency, andUpdateExchangeRateWith: completion)
    }
    
    var recentSelectedCurrencies: [MCCurrency] {
        return try! eventModel.recentUsedForeignCurrencies(fetchLimit: 5)
    }
    
    // MARK: NSObject
}
