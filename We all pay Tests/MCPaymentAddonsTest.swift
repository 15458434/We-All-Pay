//
//  MCPaymentAddonsTest.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 08/09/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

import XCTest
import CoreData
@testable import CurrencyConverter // Assuming this is the module name for CurrencyConverter
@testable import We_all_pay

class MCPaymentAddonsTest: XCTestCase {
    var context: NSManagedObjectContext!
    var eventsModel: EventsModel!

    override func setUp() {
        super.setUp()
        WeAllPayStoreController.defaultStore.openStore(of: NSInMemoryStoreType)
        context = WeAllPayStoreController.defaultStore.viewContext
        eventsModel = EventsModel(with: context, and: nil)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testMCPaymentAddons() throws {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let thisPerson = eventModel.addPerson()
        thisPerson.firstName = "Mark"
        thisPerson.lastName = "Cornelisse"
        let model = PersonModel(with: thisPerson)
        model.add(defaultEmailAddress: "support@markcornelisse.nl")
        let thisPayment = eventModel.addPayment()
        thisPayment.descriptionOfPayment = "Beer"
        thisPayment.money = NSNumber(value: 3.25)
        XCTAssertFalse(thisPayment.hasPayer, "PayerPresent")
        thisPayment.payingPerson = thisPerson
        XCTAssertTrue(thisPayment.hasPayer, "No payer present on thisPayment")
        
        try eventModel.delete(payment: thisPayment)
        XCTAssertTrue(thisPayment.isDeleted, "MCPayment table is not empty")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testCurrency() {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        // This test checks to see if currency is being setup when a new payment is being made.
        let thisPayment = eventModel.addPayment()
        let currentCurrencyCode = Locale.current.currencyCode!
        XCTAssertTrue(thisPayment.currency!.code! == currentCurrencyCode, "\(thisPayment.currency!.code!) should be the same as \(currentCurrencyCode)")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testMoneyInMainCurrency() {
        // This test checks to see if currency is correctly converted to the mainCurrency of the sharedBill.
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        event.mainCurrency = currencyModel.currency(from: "EUR")
        let thisPayment = eventModel.addPayment()
        thisPayment.currency = currencyModel.currency(from: "USD")
        let exchangeRate = eventModel.addExchangeRate(for: thisPayment)
        exchangeRate.exchangeRate = NSNumber(value: 0.7424)
        thisPayment.money = NSNumber(value: 2.97)
        let valueInMainCurrency = thisPayment.moneyInMainCurrency
        XCTAssertEqual(valueInMainCurrency.doubleValue, 0.7424 * 2.97, accuracy: 0.001, "Main value after conversion not ok. \(valueInMainCurrency) = \(0.7424 * 2.97)")
    }

    func testAddPaymentForExchangeRateCreation() {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let thisPayment = eventModel.addPayment()
        XCTAssertNotNil(thisPayment.exchangeRate, "There should be an exchangeRate in this payment.")
        XCTAssertEqual(thisPayment.exchangeRate!.exchangeRate!.doubleValue, 1.000, accuracy: 0.0001, "Value of exchangeRate should be 1.")
        XCTAssert(thisPayment.exchangeRate!.status!.int16Value == MCExchangeRateStatus.valid.rawValue, "exchangeRate status should be valid")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }
}
