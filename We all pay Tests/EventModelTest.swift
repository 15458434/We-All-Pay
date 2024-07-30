//
//  EventModelTest.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 20/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import XCTest
import Combine

final class EventModelTest: XCTestCase {
    
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
        try super.setUpWithError()
        WeAllPayStoreController.defaultStore.openStore(of: NSInMemoryStoreType)
        managedObjectContext = WeAllPayStoreController.defaultStore.viewContext
        eventsModel = EventsModel(with: managedObjectContext)
    }

    override func tearDownWithError() throws {
        managedObjectContext = nil
        eventsModel = nil
        try super.tearDownWithError()
    }
    
    // MARK: NSObject
}
