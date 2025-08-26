//
//  EventModelTest.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 20/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

@testable import We_all_pay

import XCTest
import Combine
import os

final class EventModelTest: XCTestCase {
    
    private var logger = Logger(category: "EventModelTest")
    private var managedObjectContext: NSManagedObjectContext!
    private var eventsModel: EventsModel!
    
    // MARK: XCTestCase
    
    func testUpdateExchangeRates() throws {
        let event = eventsModel.addEvent()
        let eventModel = EventModel(event: event)
        let peopleSpawningPool = PeopleSpawningPool(eventModel: eventModel)
        let mark = peopleSpawningPool.spawnMark()
        let _ = peopleSpawningPool.spawnMerit()
        let paymentSpawningPool = PaymentSpawningPool(eventModel: eventModel)
        let dinnerPayment = paymentSpawningPool.dinner(selectPayer: mark, money: 125.00)
        let paymentModel = PaymentModel(with: dinnerPayment, fromEventOf: eventModel)
        
        let expectation = XCTestExpectation(description: "Exchange rate updated")
        var bag = Set<AnyCancellable>()
        dinnerPayment.publisher(for: \MCPayment.exchangeRate!.exchangeRate, options: [.new])
            .sink { exchangeRate in
                print("exchangeRate: exchangeRate")
                if exchangeRate != 1.0 {
                    expectation.fulfill()
                }
            }
            .store(in: &bag)
        paymentModel.update(currencyFromCode: "USD")
        
        wait(for: [expectation], timeout: 60)
    }
    
    // MARK: XCTest
    
    override func setUpWithError() throws {
        logger.trace(#function)
        try super.setUpWithError()
        WeAllPayStoreController.defaultStore.openStore(of: NSInMemoryStoreType)
        logger.info("\(#function): store opened")
        managedObjectContext = WeAllPayStoreController.defaultStore.viewContext
        logger.info("\(#function): managedObjectContext set")
        eventsModel = EventsModel(with: managedObjectContext)
        logger.info("\(#function): eventsModel set")
        logger.info("\(#function): objectModel \(WeAllPayStoreController.defaultStore.container.managedObjectModel)")
        logger.info("\(#function): Context persistent store coordinator: \(WeAllPayStoreController.defaultStore.viewContext.persistentStoreCoordinator)")
    }

    override func tearDownWithError() throws {
        managedObjectContext = nil
        eventsModel = nil
        try super.tearDownWithError()
    }
    
    // MARK: NSObject
}
