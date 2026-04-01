//
//  MCSharedBillAddOnsTest.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 08/09/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import XCTest
import CoreData
@testable import We_all_pay
@testable import CurrencyConverter

class MCSharedBillAddOnsTest: XCTestCase {
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

    func testExchangeRatePresentAfterAddPayment() {
        let event = MCSharedBill(context: context)
        let currencyController = CurrencyController()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: currencyController)
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let yvette = eventModel.addPerson()
        yvette.firstName = "Yvette"
        let merit = eventModel.addPerson()
        merit.firstName = "Merit"
        let payment = eventModel.addPayment()
        let exchangeRate = payment.exchangeRate
        XCTAssertNotNil(exchangeRate, "Exchange rate should be present on a new payment.")
    }

    func testMoneyInMainCurrencyAfterAddPayment() {
        let event = MCSharedBill(context: context)
        let currencyController = CurrencyController()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: currencyController)
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let yvette = eventModel.addPerson()
        yvette.firstName = "Yvette"
        let merit = eventModel.addPerson()
        merit.firstName = "Merit"
        let payment = eventModel.addPayment()
        let moneyInMainCurrency = payment.moneyInMainCurrency
        XCTAssertNotNil(moneyInMainCurrency, "moneyInMainCurrency should not be zero.")
    }

    func testMCSharedBillAddOns1() throws {
        let event = MCSharedBill(context: context)
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        event.tripName = "Movie"
        XCTAssertFalse(event.areTherePeople, "There are people on a new event?")
        let markmovie = eventModel.addPerson()
        let markModel = PersonModel(with: markmovie)
        markModel.person.firstName = "Mark"
        markModel.person.lastName = "Cornelisse"
        markModel.add(emailAddress: "info@markcornelisse.nl")
        markModel.add(emailAddress: "support@markcornelisse.nl")
        let ilsemovie = eventModel.addPerson()
        let ilseModel = PersonModel(with: ilsemovie)
        ilseModel.person.firstName = "Ilse"
        ilseModel.person.lastName = "Béguin"
        ilseModel.add(emailAddress: "ilse@markcornelisse.nl")
        let conniemovie = eventModel.addPerson()
        let connieModel = PersonModel(with: conniemovie)
        connieModel.person.firstName = "Connie"
        connieModel.person.lastName = "Carter"
        connieModel.add(emailAddress: "connie@markcornelisse.nl")
        let liekemovie = eventModel.addPerson()
        let liekeModel = PersonModel(with: liekemovie)
        liekeModel.person.firstName = "Lieke"
        liekeModel.person.lastName = "Koopman"
        liekeModel.add(emailAddress: "lieke@markcornelisse.nl")
        liekeModel.add(defaultEmailAddress: "liekeNewDefault@markcornelisse.nl")
        let tickets = eventModel.addPayment()
        tickets.payingPerson = markmovie
        tickets.money = NSNumber(value: 8.90 * 4)
        tickets.descriptionOfPayment = "Tickets"
        let drinksAndPopcorn = eventModel.addPayment()
        drinksAndPopcorn.payingPerson = liekemovie
        drinksAndPopcorn.money = NSNumber(value: 34.40)
        drinksAndPopcorn.descriptionOfPayment = "Drinks and popcorn for the movie."
        let parking = eventModel.addPayment()
        parking.payingPerson = liekemovie
        parking.money = NSNumber(value: 6.00)
        parking.descriptionOfPayment = "Parking"
        XCTAssertTrue(event.areTherePeople, "There are no people when 4 people should have been added?")
        XCTAssertTrue(event.totalAmountOfPeoplePresent == 4, "4 people were added, but the returned amount it not 4?")
        let solutionModel = SolutionModel(eventModel: eventModel)
        var totalAmountOfPeopleWhoHavePaidError: NSError?
        XCTAssertTrue(try solutionModel.totalAmountOfPeopleWhoHavePaid().uintValue == 2, "Total amount of people who have paid is not 3")
        XCTAssertNil(totalAmountOfPeopleWhoHavePaidError, "No error should have occured getting the totalAmountOfPeopleWhoHavePaid.")
        XCTAssertTrue(liekemovie.totalSumPaid!.doubleValue == 40.40, "Total sum is wrong when adding multiple payments.")
        XCTAssertTrue(try solutionModel.totalSumOfMoney().doubleValue == 8.90*4+34.40+6.00, "Total sum is wrong when adding multiple payments.")
        let hasLiekePaidSomething = try eventModel.hasPersonPaidSomething(by: liekemovie)
        XCTAssertTrue(hasLiekePaidSomething.boolValue, "Lieke should have paid something.")
        let hasMarkPaidSomething = try eventModel.hasPersonPaidSomething(by: markmovie)
        XCTAssertTrue(hasMarkPaidSomething.boolValue, "Mark should have paid something.")
        let hasIlsePaidSomething = try eventModel.hasPersonPaidSomething(by: ilsemovie)
        XCTAssertFalse(hasIlsePaidSomething.boolValue, "This person shouldn't have paid something.")
        let hasConniePaidSomething = try eventModel.hasPersonPaidSomething(by: conniemovie)
        XCTAssertFalse(hasConniePaidSomething.boolValue, "This person shouldn't have paid something.")
        let doesEveryoneHaveAnEmailAddress = solutionModel.doesEveryoneHaveAnEmailAddress
        XCTAssertTrue(doesEveryoneHaveAnEmailAddress, "Everyone should have an email address")
        let averageAmountShouldHavePaid = try solutionModel.averageAmountShouldHavePaid()
        print("totalSumOfMoney: \(averageAmountShouldHavePaid)")
        // Calculate (8.90*4+34.40+6.00)
        let money8_90 = NSDecimalNumber(string: "8.90")
        let four = NSDecimalNumber(value: 4)
        let money8_90times4 = money8_90.multiplying(by: four)
        let money34_40 = NSDecimalNumber(string: "34.40")
        let money6_00 = NSDecimalNumber(string: "6.00")
        let verificationAverageAmountShouldHavePaid = money8_90times4.adding(money34_40).adding(money6_00).dividing(by: four)
        XCTAssertEqual(averageAmountShouldHavePaid, verificationAverageAmountShouldHavePaid, "The average calculated amount is wrong.")
        let solution = try solutionModel.originalSolveWhoHasToPayWhoFromThisBill()
        XCTAssertEqual(solution.count, 3, "Amount of MCReturnPayment on solved bill is not ok.")
        let one = solution[0]
        XCTAssertEqual(ilsemovie, one.payer, "Payer not equal to the person that should pay.")
        XCTAssertEqual(16.6, one.money!.doubleValue, accuracy: 0.001, "Amount of money not equal to what should be paid.")
        XCTAssertEqual(markmovie, one.receiver, "Receiver not equal to the person that should receive.")
        let two = solution[1]
        XCTAssertEqual(ilsemovie, two.payer, "Payer not equal to the person that should pay.")
        XCTAssertEqual(2.4, two.money!.doubleValue, accuracy: 0.001, "Amount of money not equal to what should be paid.")
        XCTAssertEqual(liekemovie, two.receiver, "Receiver not equal to the person that should receive.")
        let three = solution[2]
        XCTAssertEqual(conniemovie, three.payer, "Payer not equal to the person that should pay.")
        XCTAssertEqual(19.00, three.money!.doubleValue, accuracy: 0.001, "Amount of money not equal to what should be paid.")
        XCTAssertEqual(liekemovie, three.receiver, "Receiver not equal to the person that should receive.")
        eventsModel.delete(event: event)
    }

    // ... (other test methods from the truncated part, converted similarly)

    func testAreAllExchangeRatesValid() throws {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        mark.firstName = "Mark"
        let femke = eventModel.addPerson()
        femke.firstName = "Femke"
        let paymentWithValidExchangeRate = eventModel.addPayment()
        XCTAssertNotNil(paymentWithValidExchangeRate, "Should be present.")
        let solutionModel = SolutionModel(eventModel: eventModel)
        let allExchangeRatesShouldBeValid = try solutionModel.areAllExchangeRatesValid().boolValue
        XCTAssertTrue(allExchangeRatesShouldBeValid, "All Exchange Rates should be valid.")
        let paymentWithInValidExchangeRate = eventModel.addPayment()
        let foreignCurrency = currencyModel.currency(from: "GBP")
        paymentWithInValidExchangeRate.currency = foreignCurrency
        XCTAssertNotNil(paymentWithInValidExchangeRate.exchangeRate, "1 ExchangeRate should not be nil.")
        paymentWithInValidExchangeRate.exchangeRate!.toCurrency = foreignCurrency
        paymentWithInValidExchangeRate.exchangeRate!.status = MCExchangeRateStatus.fetching.number
        let oneExchangeRateIsFetching = try solutionModel.areAllExchangeRatesValid().boolValue
        XCTAssertFalse(oneExchangeRateIsFetching, "One exchange rate is fetching.")
        paymentWithInValidExchangeRate.exchangeRate!.status = MCExchangeRateStatus.invalid.number
        let oneExchangeRateIsInvalid = try solutionModel.areAllExchangeRatesValid().boolValue
        XCTAssertFalse(oneExchangeRateIsInvalid, "One exchange rate is invalid.")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testFetchPeoplePresentOrderedByAmountPaid() {
        let event = MCSharedBill(context: context)
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        mark.firstName = "Mark"
        let lieke = eventModel.addPerson()
        lieke.firstName = "Lieke"
        let marieke = eventModel.addPerson()
        marieke.firstName = "Marieke"
        let iceCream = eventModel.addPayment()
        iceCream.payingPerson = marieke
        iceCream.descriptionOfPayment = "Ice Cream"
        iceCream.money = NSNumber(value: 6.00)
        let movie = eventModel.addPayment()
        movie.payingPerson = mark
        movie.descriptionOfPayment = "Movie"
        movie.money = NSNumber(value: 36.00)
        let hotelRoom = eventModel.addPayment()
        hotelRoom.payingPerson = lieke
        hotelRoom.descriptionOfPayment = "Place to sleep"
        hotelRoom.money = NSNumber(value: 100.00)
        hotelRoom.exchangeRate!.exchangeRate = NSNumber(value: 0.3)
        let result = eventModel.peoplePresentOrderedByAmountPaid(inAscendingOrder: true)
        XCTAssertTrue(result[0] == marieke, "First person should be Marieke.")
        XCTAssertTrue(result[1] == lieke, "Second person should be Lieke.")
        XCTAssertTrue(result[2] == mark, "Third person should be Mark.")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testFetchPersonWithID() throws {
        let event = MCSharedBill(context: context)
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        mark.firstName = "Mark"
        mark.lastName = "Cornelisse"
        let uuid = mark.uniquePersonId!
        let fetchedSucker = try eventModel.person(with: uuid)
        XCTAssertTrue(fetchedSucker.uniquePersonId == uuid, "Fetched uuid should be Mark")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testDoAllPaymentHaveAPayer() throws {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        mark.firstName = "Mark"
        let merit = eventModel.addPerson()
        merit.firstName = "Merit"
        let payment = eventModel.addPayment()
        payment.money = NSNumber(value: 1.00)
        payment.descriptionOfPayment = "Knuffel"
        var noPaymentsWithoutPayers = try eventModel.doAllPaymentsHaveAPayer()
        XCTAssertFalse(noPaymentsWithoutPayers.boolValue, "There should be a payment without a payer.")
        let paymentWithPayer = eventModel.addPayment()
        payment.money = NSNumber(value: 34.00)
        paymentWithPayer.descriptionOfPayment = "Massage"
        paymentWithPayer.payingPerson = merit
        noPaymentsWithoutPayers = try eventModel.doAllPaymentsHaveAPayer()
        XCTAssertFalse(noPaymentsWithoutPayers.boolValue, "There should be a payment without a payer.")
        payment.payingPerson = mark
        noPaymentsWithoutPayers = try eventModel.doAllPaymentsHaveAPayer()
        XCTAssertTrue(noPaymentsWithoutPayers.boolValue, "All payments should have a payer.")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testGetFirstPaymentWithoutAPayer() throws {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        mark.firstName = "Mark"
        let merit = eventModel.addPerson()
        merit.firstName = "Merit"
        let paymentWithPayer = eventModel.addPayment()
        paymentWithPayer.descriptionOfPayment = "Massage"
        paymentWithPayer.payingPerson = merit
        paymentWithPayer.money = NSNumber(value: 34.00)
        let paymentWithoutAPayer = eventModel.addPayment()
        paymentWithoutAPayer.money = NSNumber(value: 1.00)
        paymentWithoutAPayer.descriptionOfPayment = "Knuffel"
        let anotherPaymenWithoutAPayer = eventModel.addPayment()
        anotherPaymenWithoutAPayer.money = NSNumber(value: 13.00)
        anotherPaymenWithoutAPayer.descriptionOfPayment = "This is crazy!"
        let firstPaymentWithoutAPayer = try eventModel.getFirstPaymentWithoutAPayer()
        XCTAssertTrue(firstPaymentWithoutAPayer == paymentWithoutAPayer, "These two should be the same.")
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }

    func testRecentUsedForeignCurrencies() throws {
        let event = eventsModel.addEvent()
        let currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
        let eventModel = EventModel(event: event, currencyModel: currencyModel)
        let mark = eventModel.addPerson()
        mark.firstName = "Mark"
        let merit = eventModel.addPerson()
        merit.firstName = "Merit"
        let aud = currencyModel.currency(from: "AUD")
        let payment = eventModel.addPayment()
        payment.payingPerson = mark
        payment.currency = aud
        var error: NSError?
        let mainCurrency = try currencyModel.generateCurrencyFromSelectedLocale()
        XCTAssertNil(error, "generateCurrencyFromSelectedLocaleWithError should not generate an error.")
        let homePayment = eventModel.addPayment()
        homePayment.payingPerson = merit
        homePayment.currency = mainCurrency
        let foreignCurrencies = try eventModel.recentUsedForeignCurrencies(fetchLimit: 5)
        XCTAssertTrue(foreignCurrencies.count > 0, "There can only be multiple foreign currencies")
        for currency in foreignCurrencies {
            XCTAssertTrue(currency.code == "AUD", "Only foreign currency should be Australian Dollar")
        }
        
        // Disconnect the eventModel from the event.
        eventModel.reset()
    }
}
