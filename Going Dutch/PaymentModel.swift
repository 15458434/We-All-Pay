//
//  PaymentModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 31/10/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPaymentModel) @objcMembers public final class PaymentModel: NSObject {
    @objc public private(set) dynamic var payment: MCPayment!
    private(set) var currencyFormatter: CurrencyFormatter!
    private var changeHandler: ((_ payment: MCPayment) -> ())!
    
    @objc(prepareForUseWithPayment:andChangeHandler:) func prepareForUse(with payment: MCPayment, and changeHandler:@escaping ((_ payment: MCPayment) -> ())) {
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
        
        self.changeHandler = changeHandler
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
    
    @objc(updatePayingPerson:) func update(payingPerson: MCPerson) {
        payingPerson.addPaymentsObject(payment)
        payment.payingPerson = payingPerson
        updateDateModified()
        changeHandler(payment)
    }
    
    @objc(updateCategoryWithObject:) func update(categoryObject: CategoryPictureObject) {
        payment.categoryId = NSNumber(value: categoryObject.categoryId)
        updateDateModified()
        changeHandler(payment)
    }
    
    @objc(updateDescriptionOfPayment:) func update(descriptionOfPayment: String) {
        payment.descriptionOfPayment = descriptionOfPayment
        updateDateModified()
        changeHandler(payment)
    }
    
    @objc(updateMoney:) func update(money: NSNumber) {
        payment.money = money
        payment.recalculateAveragePeopleOweAndStore()
        changeHandler(payment)
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
