//
//  MCPaymentPresenceTest.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 08/09/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import XCTest
import CoreData
@testable import We_all_pay
@testable import CurrencyConverter

class MCPaymentPresenceTest: XCTestCase {
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

    func testAddAndDelete() throws {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventmodel = EventModel(event: event, currencyModel: currencyModel)
        event.tripName = "testAddAndDelete"
        let mark = eventmodel.addPerson()
        let markModel = PersonModel(with: mark)
        mark.firstName = "Mark"
        mark.lastName = "Cornelisse"
        markModel.add(emailAddress: "info@markcornelisse.nl")
        let ilse = eventmodel.addPerson()
        let ilseModel = PersonModel(with: ilse)
        ilse.firstName = "Ilse"
        ilse.lastName = "Béguin"
        ilseModel.add(emailAddress: "ilse.beguin@hotmail.com")
        let iva = eventmodel.addPerson()
        let ivaModel = PersonModel(with: iva)
        iva.firstName = "Iva"
        iva.lastName = "Moslavac"
        ivaModel.add(emailAddress: "ivamavi2002@yahoo.co.uk")
        
        let firstPayment = eventmodel.addPayment()
        XCTAssertTrue(firstPayment.peopleSharingPayment!.count == event.peoplePresent!.count, "Amount of people from the sharedBill is not correct.")
        let thesePeopleOnThisPayment = firstPayment.peopleSharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        thesePeopleOnThisPayment.forEach { paymentPresence in
            XCTAssertTrue( paymentPresence.isPersonPresent!.boolValue, "Person should be present on first creation of the payment.")
        }
        try eventmodel.delete(payment: firstPayment)
        for paymentPresence in thesePeopleOnThisPayment {
            XCTAssertTrue(paymentPresence.isDeleted, "This person should be deleted.")
        }
        
        let secondPayment = eventmodel.addPayment()
        secondPayment.money = NSNumber(value: 8.90)
        secondPayment.payingPerson = iva
        secondPayment.descriptionOfPayment = "Ice cream"
        let ppSecondPayment = secondPayment.peopleSharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        eventsModel.delete(event: event)
        XCTAssertTrue(secondPayment.isDeleted, "The secondPayment should be deleted.")
        let payments = event.payments as? Set<MCPayment> ?? Set<MCPayment>()
        for payment in payments {
            XCTAssertTrue(payment.isDeleted, "Payment should have been deleted.")
        }
        for pp in ppSecondPayment {
            XCTAssertTrue(pp.isDeleted, "People presence is not deleted on MCSharedbill delete.")
        }
        // Disconnect the eventModel from the event.
        eventmodel.reset()
    }

    func testPeoplePresent() {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        let markModel = PersonModel(with: mark)
        markModel.person.firstName = "Mark"
        markModel.person.lastName = "Cornelisse"
        markModel.add(emailAddress: "info@markcornelisse.nl")
        let ilse = eventModel.addPerson()
        let ilseModel = PersonModel(with: ilse)
        ilseModel.person.firstName = "Ilse"
        ilseModel.person.lastName = "Béguin"
        ilseModel.add(emailAddress: "ilse.beguin@hotmail.com")
        let iva = eventModel.addPerson()
        let ivaModel = PersonModel(with: iva)
        ivaModel.person.firstName = "Iva"
        ivaModel.person.lastName = "Moslavac"
        ivaModel.add(emailAddress: "ivamavi2002@yahoo.co.uk")
        
        let thisPayment = eventModel.addPayment()
        XCTAssertTrue(thisPayment.peoplePresentOnThisPayment == 3 , "There should be three people present on this payment.")
        let thePeopleOfTheBill = thisPayment.peopleSharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        let pp = thePeopleOfTheBill.first!
        pp.isPersonPresent = NSNumber(value: false)
        XCTAssertTrue(thisPayment.peoplePresentOnThisPayment == 2, "Two out of three people should be present on this payment")
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testAveragePeopleShouldPay() throws {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        let markModel = PersonModel(with: mark)
        markModel.person.firstName = "Mark"
        markModel.person.lastName = "Cornelisse"
        markModel.add(emailAddress: "info@markcornelisse.nl")
        let ilse = eventModel.addPerson()
        let ilseModel = PersonModel(with: ilse)
        ilseModel.person.firstName = "Ilse"
        ilseModel.person.lastName = "Béguin"
        ilseModel.add(emailAddress: "ilse.beguin@hotmail.com")
        let iva = eventModel.addPerson()
        let ivaModel = PersonModel(with: iva)
        ivaModel.person.firstName = "Iva"
        ivaModel.person.lastName = "Moslavac"
        ivaModel.add(emailAddress: "ivamavi2002@yahoo.co.uk")
        
        let thisPayment = eventModel.addPayment()
        let paymentModel = PaymentModel(with: thisPayment, fromEventOf: eventModel)
        thisPayment.money = NSNumber(value: 9.00)
        paymentModel.recalculateAveragePeopleOweAndStore()
        let average = 9.00 / 3.00
        
        XCTAssertEqual(average, thisPayment.averageAmountPeopleShouldHavePaidOnThisPayment, accuracy: 0.01, "The average amount of money is different, from what I'm calculating.")
        let thisPaymentPeopleSharingPayment = thisPayment.peopleSharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        thisPaymentPeopleSharingPayment.forEach { paymentPresence in
            XCTAssertEqual(average, paymentPresence.averageOweFromPayment!.doubleValue, accuracy: 0.01, "Average amount stored is not ok.")
        }
        
        // Test [thisPayment recalculateAveragePeopleOweAndStore]
        thisPaymentPeopleSharingPayment.first!.isPersonPresent = NSNumber(value: false)
        paymentModel.recalculateAveragePeopleOweAndStore()
        thisPaymentPeopleSharingPayment.forEach { paymentPresence in
            if paymentPresence.isPersonPresent!.boolValue {
                XCTAssertEqual(4.50, paymentPresence.averageOweFromPayment!.doubleValue, accuracy: 0.01, "Average amount stored is not ok.")
            } else {
                XCTAssertEqual(0.00, paymentPresence.averageOweFromPayment!.doubleValue, accuracy: 0.01, "Average amount stored is not ok.")
            }
        }
        
        // Test [thisPayment fetchPaymentPresenceForPerson:]
        let thisPayment2 = eventModel.addPayment()
        let payment2Model = PaymentModel(with: thisPayment2, fromEventOf: eventModel)
        thisPayment2.money = NSNumber(value: 60.00)
        thisPayment2.descriptionOfPayment = "Bier of some sort."
        let ppMarkOnThisPayment2 = try payment2Model.paymentPresence(for: mark)
        XCTAssertTrue(ppMarkOnThisPayment2.person! == mark && ppMarkOnThisPayment2.payment! == thisPayment2, "The paymentPresence fetched is the correct one.")
        
        // Test [thisPayment thisPerson: isPresent:]
        try payment2Model.update(person: mark, to: false)
        XCTAssertFalse(ppMarkOnThisPayment2.isPersonPresent!.boolValue, "Mark should not be present.")
        var thisPayment2PeopleSharingPayment = thisPayment2.peopleSharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        thisPayment2PeopleSharingPayment.forEach { paymentPresence in
            if paymentPresence.isPersonPresent!.boolValue {
                XCTAssertEqual(60.00/2, paymentPresence.averageOweFromPayment!.doubleValue, accuracy: 0.01, "Average amount not updated on toggle.")
            } else {
                XCTAssertEqual(0.00, paymentPresence.averageOweFromPayment!.doubleValue, accuracy: 0.01, "Average amount not resetted by now presence.")
            }
        }
        try payment2Model.update(person: mark, to: true)
        
        XCTAssertTrue(ppMarkOnThisPayment2.isPersonPresent!.boolValue, "Mark should not be present.")
        
        thisPayment2PeopleSharingPayment = thisPayment2.peopleSharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        thisPayment2PeopleSharingPayment.forEach { paymentPresence in
            if paymentPresence.isPersonPresent!.boolValue {
                XCTAssertEqual(60.00/3, paymentPresence.averageOweFromPayment!.doubleValue, accuracy: 0.01, "Average amount not updated on toggle.")
            } else {
                XCTAssertEqual(0.00, paymentPresence.averageOweFromPayment!.doubleValue, accuracy: 0.01, "Average amount not resetted by now presence.")
            }
        }
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testSolveWhoHasToPayWho() throws {
        let event = eventsModel.addEvent()
        let eventModel = EventModel(event: event)
        let solutionModel = SolutionModel(eventModel: eventModel)
        let mark = eventModel.addPerson()
        let markModel = PersonModel(with: mark)
        markModel.person.firstName = "Mark"
        markModel.person.lastName = "Cornelisse"
        markModel.add(emailAddress: "info@markcornelisse.nl")
        let femke = eventModel.addPerson()
        let femkeModel = PersonModel(with: femke)
        femkeModel.person.firstName = "Femke"
        femkeModel.person.lastName = "van Haaren"
        femkeModel.add(emailAddress: "femkevanhaaren@hotmail.com")
        let iva = eventModel.addPerson()
        let ivaModel = PersonModel(with: iva)
        ivaModel.person.firstName = "Iva"
        ivaModel.person.lastName = "Moslavac"
        ivaModel.add(emailAddress: "ivamavi2002@yahoo.co.uk")
        
        let thisPayment = eventModel.addPayment()
        let paymentModel = PaymentModel(with: thisPayment, fromEventOf: eventModel)
        thisPayment.payingPerson = mark
        thisPayment.descriptionOfPayment = "Drinken op een terras."
        thisPayment.money = NSNumber(value: 9.00)
        try paymentModel.update(person: femke, to: false)
        
        let thisPayment2 = eventModel.addPayment()
        thisPayment2.payingPerson = iva
        thisPayment2.descriptionOfPayment = "Food"
        thisPayment2.money = NSNumber(value: 30.00)
        
        let thisPayment3 = eventModel.addPayment()
        let payment3Model = PaymentModel(with: thisPayment3, fromEventOf: eventModel)
        thisPayment3.payingPerson = femke
        thisPayment3.descriptionOfPayment = "Movie"
        thisPayment3.money = NSNumber(value: 36.00)
        try payment3Model.update(person: mark, to: false)
        
        let solution = try solutionModel.originalSolveWhoHasToPayWhoFromThisBill()
        print("solution: \(solution)")
        XCTAssertTrue(solution.count == 2, "The amount of objects in the solution is not ok.")
        let firstReturnPayment = solution[0]
        XCTAssertEqual(firstReturnPayment.money!.doubleValue, 5.50, accuracy: 0.001, "The amount Mark should pay is not 5.50.")
        let secondReturnPayment = solution[1]
        XCTAssertEqual(secondReturnPayment.money!.doubleValue, 2.50, accuracy: 0.001, "The amount Iva should pay is not 2.50.")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testaddLateArrivalPaymentPresenceFor() {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        event.tripName = "Movie"
        let mark = eventModel.addPerson()
        let markModel = PersonModel(with: mark)
        markModel.person.firstName = "Mark"
        markModel.person.lastName = "Cornelisse"
        markModel.add(emailAddress: "info@markcornelisse.nl")
        let ilse = eventModel.addPerson()
        let ilseModel = PersonModel(with: ilse)
        ilseModel.person.firstName = "Ilse"
        ilseModel.person.lastName = "Béguin"
        ilseModel.add(emailAddress: "ilse.beguin@hotmail.com")
        
        let thisPayment = eventModel.addPayment()
        thisPayment.payingPerson = mark
        thisPayment.descriptionOfPayment = "Movie tickets"
        thisPayment.money = NSNumber(value: 26.70)
        thisPayment.onWhichBill = event
        
        let iva = eventModel.addPerson()
        let ivaModel = PersonModel(with: iva)
        ivaModel.person.firstName = "Iva"
        ivaModel.person.lastName = "Moslavac"
        ivaModel.add(emailAddress: "ivamavi2002@yahoo.co.uk")
        
        let thisPaymentPeopleSharingPayment = thisPayment.peopleSharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        XCTAssertEqual(thisPaymentPeopleSharingPayment.count, 3, "There can only be 3 people sharing this payment.")
        let ivaSharingPayment = iva.sharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        ivaSharingPayment.forEach { paymentPresence in
            XCTAssertFalse(paymentPresence.isPersonPresent!.boolValue, "Iva should not be present.")
        }
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testDeletePersonWithPresences() throws {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        let markModel = PersonModel(with: mark)
        markModel.person.firstName = "Mark"
        markModel.person.lastName = "Cornelisse"
        markModel.add(emailAddress: "info@markcornelisse.nl")
        let ilse = eventModel.addPerson()
        let ilseModel = PersonModel(with: ilse)
        ilseModel.person.firstName = "Ilse"
        ilseModel.person.lastName = "Béguin"
        ilseModel.add(emailAddress: "ilse.beguin@hotmail.com")
        let iva = eventModel.addPerson()
        let ivaModel = PersonModel(with: iva)
        ivaModel.person.firstName = "Iva"
        ivaModel.person.lastName = "Moslavac"
        ivaModel.add(emailAddress: "ivamavi2002@yahoo.co.uk")
        
        let thisPayment = eventModel.addPayment()
        thisPayment.payingPerson = mark
        thisPayment.descriptionOfPayment = "Drinken op een terras."
        thisPayment.money = NSNumber(value: 9.00)
        
        let thisPayment2 = eventModel.addPayment()
        thisPayment2.payingPerson = iva
        thisPayment2.descriptionOfPayment = "Food"
        thisPayment2.money = NSNumber(value: 30.00)
        
        let thisPayment3 = eventModel.addPayment()
        thisPayment3.payingPerson = ilse
        thisPayment3.descriptionOfPayment = "Movie"
        thisPayment3.money = NSNumber(value: 36.00)
        
        XCTAssertEqual(iva.sharingPayment!.count, 3, "There should be 3 paymentPresences for Iva.")
        var ivaSharingPayment = iva.sharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        XCTAssertEqual(thisPayment.peopleSharingPayment!.count, 3, "There should be 3 paymentPresences on the first payment.")
        eventModel.delete(person: iva)
        XCTAssertEqual(thisPayment.peopleSharingPayment!.count, 2, "There should be 2 paymentPresences left on this payment.")
        XCTAssertTrue(iva.isDeleted, "Iva should be removed.")
        ivaSharingPayment = iva.sharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        ivaSharingPayment.forEach { XCTAssertTrue($0.isDeleted, "Payment presence of Iva should be deleted.") }
        let solutionModel = SolutionModel(eventModel: eventModel)
        XCTAssertEqual(try solutionModel.amountShouldHavePaid(by: mark).doubleValue, 37.5, accuracy: 0.001, "payment presence not updated after deletion.")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testGetAverageOweFromPaymentInMainCurrency() throws {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mainCurrency = try currencyModel.generateCurrencyFromSelectedLocale()
        event.mainCurrency = mainCurrency
        let marieke = eventModel.addPerson()
        marieke.firstName = "Marieke"
        marieke.lastName = "Siemensma"
        let merit = eventModel.addPerson()
        merit.firstName = "Merit"
        merit.lastName = "Koelink"
        let thisPayment = eventModel.addPayment()
        let paymentModel = PaymentModel(with: thisPayment, fromEventOf: eventModel)
        let paymentCurrency = currencyModel.currency(from: "USD")
        thisPayment.currency = paymentCurrency
        thisPayment.descriptionOfPayment = "Thee and cookies"
        thisPayment.payingPerson = marieke
        thisPayment.money = NSNumber(value: 4.50)
        paymentModel.recalculateAveragePeopleOweAndStore()
        let exchangeRate = MCExchangeRate(context: context)
        exchangeRate.toCurrency = mainCurrency
        exchangeRate.fromCurrency = paymentCurrency
        exchangeRate.exchangeRate = NSNumber(value: 0.72)
        exchangeRate.payment = thisPayment
        let thisPaymentPeopleSharingPayment = thisPayment.peopleSharingPayment as? Set<MCPaymentPresence> ?? Set<MCPaymentPresence>()
        thisPaymentPeopleSharingPayment.forEach { paymentPresence in
            XCTAssertEqual(paymentPresence.averageOweFromPaymentInMainCurrency.doubleValue, 2.25 * 0.72, accuracy: 0.001, "Invalid value for getAverageOweFromPaymentInMainCurrency.")
        }
    }
}
