//
//  MCEventsModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 23/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCEventsModel) @objcMembers final class EventsModel: NSObject {
    private(set) var managedObjectContext: NSManagedObjectContext!
    
    private(set) var fetchEventsController: NSFetchedResultsController<MCSharedBill>!
    
    @objc(prepareForUseWithManagedObjectContext:forDelegate:) func prepareForUse(with managedObjectContext: NSManagedObjectContext, for delegate: NSFetchedResultsControllerDelegate) {
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
        createFetchEventsController()
    }
    
    func update(eventAt index: Int, mainCurrencyTo currencyCode: String, with completionHandler: @escaping ((_ event: MCSharedBill) -> ()), andWith failureHandler: ((_ error: Error?) -> ())? ) {
        let event = self.fetchEventsController.fetchedObjects![index]
        event.updateMainCurrency(fromCode: currencyCode) { (error) in
            guard error == nil else {
                failureHandler?(error)
                return
            }
            completionHandler(event)
        }
    }
    
    func delete(event: MCSharedBill) {
        let objectID = event.objectID
        let poorSucker = self.managedObjectContext.object(with: objectID)
        managedObjectContext.delete(poorSucker)
    }
    
    // MARK: NSObject
}
