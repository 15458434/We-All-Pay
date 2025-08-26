//
//  WeAllPayStoreTests.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 08/09/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import XCTest
import CoreData
@testable import We_all_pay
@testable import CurrencyConverter

class WeAllPayStoreTests: XCTestCase {
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

    func testMCPersonAddonsGetName() {
        let thisPerson = MCPerson(context: context)
        let model = PersonModel(with: thisPerson)
        model.person.firstName = "Connie"
        model.person.lastName = "Carter"
        model.add(emailAddress: "connie@markcornelisse.nl")
        XCTAssertTrue(thisPerson.name == "Connie", "First name is not selected when it's available.")
        XCTAssertTrue(thisPerson.fullName == "Connie Carter")
        let thisPersonWithMissingFirstName = MCPerson(context: context)
        let modelWithMissingFirstName = PersonModel(with: thisPersonWithMissingFirstName)
        modelWithMissingFirstName.person.lastName = "Carter"
        modelWithMissingFirstName.add(emailAddress: "connie@markcornelisse.nl")
        XCTAssertTrue(thisPersonWithMissingFirstName.name == "Carter", "Last is not selected when first name is not available")
        XCTAssertTrue(thisPersonWithMissingFirstName.fullName == "Carter", "Fullname is wrong when first name is missing.")
        let thisPersonWithMissingFirstAndLastName = MCPerson(context: context)
        let modelWithMissingFirstAndLastName = PersonModel(with: thisPersonWithMissingFirstAndLastName)
        modelWithMissingFirstAndLastName.add(emailAddress: "connie@markcornelisse.nl")
        XCTAssertTrue(thisPersonWithMissingFirstAndLastName.name == "connie@markcornelisse.nl", "emailAddress is not selected when both first and lastname are not selected.")
        XCTAssertTrue(thisPersonWithMissingFirstAndLastName.fullName == "connie@markcornelisse.nl", "emailAddress is not selected when both first and lastnames are not selected.")
    }

    func testPersonExistenceOnSharedBill() {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        let markModel = PersonModel(with: mark)
        markModel.person.firstName = "Mark"
        markModel.person.lastName = "Cornelisse"
        markModel.add(emailAddress: "info@markcornelisse.nl")
        markModel.add(emailAddress: "support@markcornelisse.nl")
        markModel.add(defaultEmailAddress: "m.p.cornelisse@gmail.com")
        XCTAssertEqual("m.p.cornelisse@gmail.com", mark.defaultEmailAddress, "Default emailAddress is not right.")
        let markFirstName = "Mark"
        let markLastName = "Cornelisse"
        let markDefaultEmailAddress = "m.p.cornelisse@gmail.com"
        XCTAssertTrue(event.isPresent(firstName: markFirstName, lastName: markLastName, emailAddress: markDefaultEmailAddress), "Person is not present.")
        let ilseFirstName = "Ilse"
        let ilseLastName = "Béguin"
        let ilseDefaultEmailAddress = "ilse.beguin@hotmail.com"
        XCTAssertFalse(event.isPresent(firstName: ilseFirstName, lastName: ilseLastName, emailAddress: ilseDefaultEmailAddress), "Person is present.")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testGetPeopleOnSharedBill() {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        var peoplePresentOnEvent = eventModel.peoplePresentOnEvent
        XCTAssertTrue(peoplePresentOnEvent.count == 0, "Aantal mensen op the shared Bill klopt niet.")
        let thisPerson = eventModel.addPerson()
        thisPerson.firstName = "Mark"
        peoplePresentOnEvent = eventModel.peoplePresentOnEvent
        XCTAssertTrue(peoplePresentOnEvent.count == 1, "Aantal mensen op the shared Bill klopt niet.")
        let thisPerson2 = eventModel.addPerson()
        thisPerson2.firstName = "Ilse"
        peoplePresentOnEvent = eventModel.peoplePresentOnEvent
        XCTAssertTrue(peoplePresentOnEvent.count == 2, "Aantal mensen op the shared Bill klopt niet.")
        let thisPerson3 = eventModel.addPerson()
        thisPerson3.firstName = "Iva"
        peoplePresentOnEvent = eventModel.peoplePresentOnEvent
        XCTAssertTrue(peoplePresentOnEvent.count == 3, "Aantal mensen op the shared Bill klopt niet.")
        eventsModel.delete(event: event)
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testGetEmailaddressesFrom() {
        let thisPerson = MCPerson(context: context)
        let personModel = PersonModel(with: thisPerson)
        personModel.person.firstName = "Mark"
        personModel.person.lastName = "Cornelisse"
        let emailAddressMark = "info@markcornelisse.nl"
        personModel.add(emailAddress: emailAddressMark)
        let firstEmailAddressObject = thisPerson.defaultEmailAddressObject!
        let emailAddress2Mark = "mark.cornelisse@yahoo.com"
        personModel.add(emailAddress: emailAddress2Mark)
        personModel.add(emailAddress: emailAddress2Mark)
        let emailAddress3Mark = "m.p.cornelisse@gmail.com"
        personModel.add(defaultEmailAddress: emailAddress3Mark)
        personModel.update(default: firstEmailAddressObject)
        personModel.prepareForUse(withPerson: thisPerson)
        let theEmailAddressObjects = personModel.emailaddresses
        XCTAssertTrue(theEmailAddressObjects.count == 3, "The wrong amount of objects is present.")
        personModel.deleteAllEmailAddresses()
        context.delete(personModel.person)
    }
}
