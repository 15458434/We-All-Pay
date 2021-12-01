//
//  PaymentModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 31/10/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit
import CurrencyConverter

@objc(MCPaymentModel) @objcMembers public final class PaymentModel: NSObject {
    @objc public private(set) dynamic var payment: MCPayment!
    private(set) var currencyFormatter: CurrencyFormatter!
    @objc dynamic var error: NSError?

    @objc(prepareForUseWithPayment:) func prepareForUse(with payment: MCPayment) {
        func createPeoplePresenceController(for payment: MCPayment) {
            let request = MCPaymentPresence.fetchRequest()
            request.relationshipKeyPathsForPrefetching = [ "person", "payment", "payment.currency", "onWhichBill.mainCurrency", "payment.exchangeRate" ]
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPaymentPresence.dateCreated, ascending: false)]
            request.predicate = NSPredicate(format: "payment = %@", payment)
            
            peoplePresenceController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: payment.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            
        }
        self.payment = payment
        createPeoplePresenceController(for: payment)
        currencyFormatter = CurrencyFormatter(currencyCode: payment.currency!.code!)
    }
    
    private(set) var peoplePresenceController: NSFetchedResultsController<MCPaymentPresence>!
    
    var arrayOfPeoplePresent: [MCPerson] {
        return self.payment.onWhichBill!.getArrayOfPeopleSortedOnFullNames()
    }
    
    var suggestedNextPayer: MCPerson? {
        let peoplePresent = payment.onWhichBill!.fetchPeoplePresentOrdered(byAmountPaid: true)
        return peoplePresent?.first
    }
    
    func beginUpdates() {
        payment.managedObjectContext!.undoManager!.beginUndoGrouping()
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
        payment.recalculateAveragePeopleOweAndStore()
    }
    
    @objc(updateCurrency:) func update(currency: Currency) {
        currencyFormatter = CurrencyFormatter(currencyCode: currency.code)
        let mainThreadContext = payment.managedObjectContext!
        let newCurrency = MCCurrency(from: currency.code, from: mainThreadContext)
        let oldCurrency = payment.currency
        payment.currency = newCurrency
        if oldCurrency?.sharedBill?.count == 0 && oldCurrency?.payment?.count == 0 {
            mainThreadContext.delete(oldCurrency!)
        }
        
        payment.setNewCurrencyAndAutomaticallyUpdateExchangeRate(newCurrency) { [weak self] error in
            guard error == nil else {
                // TODO: Handle error
                self?.error = error! as NSError
                return
            }
        }
    }
    
    @nonobjc private func updateDateModified() {
        let nu = Date()
        payment.dateModified = nu
        payment.onWhichBill!.dateModified = nu
    }
    
    func endUpdates() {
        payment.managedObjectContext!.undoManager!.endUndoGrouping()
    }
    
    // MARK: NSObject
}
