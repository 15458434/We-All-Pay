//
//  MCPersonAddonsTest.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 08/09/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import XCTest
import CoreData
@testable import CurrencyConverter
@testable import We_all_pay

class MCPersonAddonsTest: XCTestCase {
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

    func testMCPersonAddonsAddAndDeleteEmailAddress() {
        let thisPerson = MCPerson(context: context)
        let model = PersonModel(with: thisPerson)
        thisPerson.firstName = "Mark"
        thisPerson.lastName = "Cornelisse"
        let emailAddressMark = "info@markcornelisse.nl"
        model.add(emailAddress: emailAddressMark)
        XCTAssertTrue(thisPerson.hasEmailAddress, "There is no emailAddress present when one had just been added.")
        XCTAssertTrue(thisPerson.defaultEmailAddress == emailAddressMark, "emailAddress Stored is not equal to the new default one")
        let emailAddress2Mark = "mark.cornelisse@yahoo.com"
        model.add(emailAddress: emailAddress2Mark)
        XCTAssertTrue(thisPerson.hasEmailAddress, "There is no emailAddress present when two has been added.")
        XCTAssertTrue(thisPerson.defaultEmailAddress == emailAddressMark, "emailAddress Stored is not equal to the first one")
        model.add(emailAddress: emailAddress2Mark)
        XCTAssertTrue(thisPerson.emailAddress?.count ?? 0 == 2, "Adding two times the same emailAddress is possible.")
        let emailAddress3Mark = "m.p.cornelisse@gmail.com"
        model.add(defaultEmailAddress: emailAddress3Mark)
        XCTAssertTrue(thisPerson.defaultEmailAddress == emailAddress3Mark, "addNewDefaultEmailAddress failes to set the right defaultEmailAddress")

        let emailAddresses = thisPerson.emailAddress as? Set<MCEmailAddress> ?? Set<MCEmailAddress>()
        let amountOfSelectedEmailAddresses = emailAddresses.reduce(0) { partialResult, email in
            if email.selected!.boolValue {
                return partialResult + 1
            } else {
                return partialResult
            }
        }
        XCTAssertTrue(amountOfSelectedEmailAddresses == 1, "Only one emailaddress should have be default.")
        XCTAssertTrue(thisPerson.emailAddress!.count == 3, "All emailAddresses have been entered.")
        
        let personModel = PersonModel()
        personModel.prepareForUse(withPerson: thisPerson)
        let toBeDeletedEmailAddress = personModel.defaultEmailaddress!
        personModel.delete(toBeDeletedEmailAddress)
        XCTAssertTrue(thisPerson.emailAddress!.count == 2, "Different amount of emailAddresses then expected.")
        XCTAssertTrue(thisPerson.defaultEmailAddressObject != nil, "No new defaultEmailAddress present")
        personModel.deleteAllEmailAddresses()
        XCTAssertFalse(thisPerson.hasEmailAddress, "There is an emailAddress present when two has been added.")
        XCTAssertFalse(MCPerson.isTableInDatabaseEmpty(for: context), "No people left in the database")
        context.delete(personModel.person)
        XCTAssertTrue(thisPerson.isDeleted, "This person will be deleted at the next save.")
    }

    func testSetNewDefaultEmailaddressObject() {
        let thisPerson = MCPerson(context: context)
        let markModel = PersonModel(with: thisPerson)
        thisPerson.firstName = "Mark"
        thisPerson.lastName = "Cornelisse"
        
        let emailAddressMark = "info@markcornelisse.nl"
        markModel.add(emailAddress: emailAddressMark)
        XCTAssertTrue(thisPerson.hasEmailAddress, "There is no emailAddress present when one had just been added.")
        XCTAssertTrue(thisPerson.defaultEmailAddress == emailAddressMark, "emailAddress Stored is not equal to the new default one")
        let firstEmailAddressObject = thisPerson.defaultEmailAddressObject!
        XCTAssertTrue(firstEmailAddressObject.emailAddress == emailAddressMark, "Emailaddress stored is not the one retrieved.")
        let emailAddress2Mark = "mark.cornelisse@yahoo.com"
        markModel.add(emailAddress: emailAddress2Mark)
        XCTAssertTrue(thisPerson.hasEmailAddress, "There is no emailAddress present when two has been added.")
        XCTAssertTrue(thisPerson.defaultEmailAddress! == emailAddressMark, "emailAddress Stored is not equal to the first one")
        markModel.add(emailAddress: emailAddress2Mark)
        XCTAssertTrue(thisPerson.emailAddress!.count == 2, "Adding two times the same emailAddress is possible.")
        let emailAddress3Mark = "m.p.cornelisse@gmail.com"
        markModel.add(defaultEmailAddress: emailAddress3Mark)
        XCTAssertTrue(thisPerson.defaultEmailAddress == emailAddress3Mark, "addNewDefaultEmailAddress failes to set the right defaultEmailAddress")
        markModel.update(default: firstEmailAddressObject)
        XCTAssertTrue(thisPerson.defaultEmailAddress == emailAddressMark, "setNewDefaultEmailaddressObject failes to set the correct defaultEmailAddress")
        markModel.deleteAllEmailAddresses()
        context.delete(markModel.person)
    }

    func testHasPersonMadePaymentWithInvalidExchangeRates() {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        let thisPayment = eventModel.addPayment()
        thisPayment.payingPerson = mark
        thisPayment.exchangeRate!.status = MCExchangeRateStatus.valid.number
        XCTAssertFalse(mark.hasPersonMadePaymentWithInvalidExchangeRates, "All payments person has made should be valid.")
        thisPayment.exchangeRate!.status = MCExchangeRateStatus.invalid.number
        XCTAssertTrue(mark.hasPersonMadePaymentWithInvalidExchangeRates, "No payment should be valid.")
        thisPayment.exchangeRate!.status = MCExchangeRateStatus.fetching.number
        XCTAssertTrue(mark.hasPersonMadePaymentWithInvalidExchangeRates, "No payment should be valid.")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testTotalSumPaidBy() {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let fred = eventModel.addPerson()
        fred.firstName = "Fred"
        let anna = eventModel.addPerson()
        anna.firstName = "Marieke"
        let drinks = eventModel.addPayment()
        drinks.payingPerson = fred
        drinks.money = NSNumber(value: 10)
        drinks.descriptionOfPayment = "coffee"
        let totalPaidByFred = fred.totalSumPaid!
        XCTAssertEqual(totalPaidByFred.doubleValue, 10.0, accuracy: 0.001)
        
        // Test with missing no payment presence
        let tickets = eventModel.addPayment()
        tickets.payingPerson = anna
        tickets.money = NSNumber(value: 20)
        let peopleSharingPayment = tickets.peopleSharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        peopleSharingPayment.forEach { presence in
            presence.isPersonPresent = NSNumber(value: false)
        }
        XCTAssertEqual(fred.totalSumPaid!.doubleValue, 10.0, accuracy: 0.001)
        XCTAssertEqual(anna.totalSumPaid!.doubleValue, 20.0, accuracy: 0.001)
    }
}
