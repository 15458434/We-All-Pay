//
//  EventsModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 23/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit
import CurrencyConverter

@objc(MCEventsModel) @objcMembers final class EventsModel: NSObject {
    enum Error: Swift.Error {
        case expectedResultNotFound
    }
    private(set) var managedObjectContext: NSManagedObjectContext!
    
    private(set) var fetchEventsController: NSFetchedResultsController<MCSharedBill>!
    
    @objc(initWithManagedObjectContext:andFetchedResultsControllerdDelegate:) convenience init(with managedObjectContext: NSManagedObjectContext, and fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate? = nil) {
        self.init()
        prepareForUse(with: managedObjectContext, and: fetchedResultsControllerDelegate)
    }
    
    @objc(prepareForUseWithManagedObjectContext:andFetchedResultsControllerdDelegate:) func prepareForUse(with managedObjectContext: NSManagedObjectContext, and delegate: NSFetchedResultsControllerDelegate? = nil) {
        func createFetchEventsController() {
            let request = MCSharedBill.fetchRequest()
            request.predicate = NSPredicate(value: true)
            request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
            request.relationshipKeyPathsForPrefetching = [ "payments", "peoplePresent", "mainCurrency", "payments.exchangeRate", "payments.peopleSharingPayment" ]
            fetchEventsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchEventsController.delegate = delegate
            try! fetchEventsController.performFetch()
        }
        
        self.managedObjectContext = managedObjectContext
        if delegate != nil {
            createFetchEventsController()
        }
    }
    
    @objc(addEvent) func addEvent() -> MCSharedBill {
        MCSharedBill(context: managedObjectContext)
    }
    
    @objc func event(with uniqueId: String) throws -> MCSharedBill {
        let request = MCSharedBill.fetchRequest()
        request.predicate = NSPredicate(format: "uniqueBillId = %@", uniqueId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCSharedBill.dateCreated, ascending: true)]
        let events = try managedObjectContext.fetch(request)
        guard events.count == 1 else {
            throw Error.expectedResultNotFound
        }
        return events.first!
    }
    
    func update(eventAt index: Int, mainCurrencyTo currencyCode: String, with completionHandler: @escaping ((_ event: MCSharedBill) -> ()), andWith failureHandler: ((_ error: Swift.Error?) -> ())? ) {
        let event = self.fetchEventsController.fetchedObjects![index]
        let currencyController = CurrencyController()
        let currencyModel = CurrencyModel(managedObjectContext: managedObjectContext, currencyController: currencyController)
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        eventModel.update(mainCurrencyFrom: currencyCode) { error in
            guard error == nil else {
                failureHandler?(error)
                return
            }
            completionHandler(event)
        }
    }
    
    func delete(event: MCSharedBill) {
        event.payments?.forEach({ payment in
            let payment = payment as! MCPayment
            payment.peopleSharingPayment?.forEach({ paymentPresence in
                let paymentPresence = paymentPresence as! MCPaymentPresence
                managedObjectContext.delete(paymentPresence)
            })
            managedObjectContext.delete(payment)
        })
        
        event.peoplePresent?.forEach({ person in
            let person = person as! MCPerson
            let emailAddresses = person.emailAddress as? Set<MCEmailAddress>
            emailAddresses?.forEach({ emailAddress in
                let emailAddress = emailAddress
                managedObjectContext.delete(emailAddress)
            })
            managedObjectContext.delete(person)
        })
        
        managedObjectContext.delete(event)
    }
    
    @objc(deleteIfStillNewEvent:) func deleteIfStillNew(event: MCSharedBill) {
        let tripName = event.tripName
        let payments = event.payments as? Set<MCPayment>
        let peoplePresent = event.peoplePresent as? Set<MCPerson>
        if (tripName?.isEmpty ?? true) && (payments?.isEmpty ?? true) && (peoplePresent?.isEmpty ?? true) {
            self.delete(event: event)
        }
    }
    
    // MARK: NSObject
}
