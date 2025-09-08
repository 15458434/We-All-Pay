//
//  EventModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 06/12/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit
import Combine
import os

import CurrencyConverter

@objc(MCEventModel) final class EventModel: NSObject, CurrencyUpdateModel {
    enum Error: Swift.Error, CustomNSError {
        case invalidPayment(MCPayment)
        case nilValue
        case managedObjectContextNotPresentOnEvent(MCSharedBill)
        
        // MARK: CustomNSError
        
        static var errorDomain: String {
            "com.markcornelisse.weallpay.EventModelErrorDomain"
        }
        
        var errorCode: Int {
            switch self {
            case .invalidPayment(_):
                return 1_000_001
            case .nilValue:
                return 1_000_002
            case .managedObjectContextNotPresentOnEvent(_):
                return 1_000_003
            }
        }
        
        var errorUserInfo: [String : Any] {
            var userInfo = [String: Any]()
            switch self {
            case .invalidPayment(let payment):
                userInfo[NSLocalizedDescriptionKey] = "Invalid payment"
                userInfo["payment"] = payment
            case .nilValue:
                userInfo[NSLocalizedDescriptionKey] = "Nil value"
            case .managedObjectContextNotPresentOnEvent(let event):
                userInfo[NSLocalizedDescriptionKey] = "Managed object context not present on event"
                userInfo["event"] = event
            }
            return userInfo
        }
    }
    
    @objc dynamic var event: MCSharedBill!
    @objc private(set) var currencyModel: CurrencyModel!
    @objc dynamic var mainCurrencyFormatter: CurrencyFormatter!
    @objc var dateFormatter: DateFormatter!
    
    private var logger = Logger(category: "EventModel")
    
    @objc(initWithEvent:) convenience init(event: MCSharedBill) {
        self.init()
        let currencyController = CurrencyController()
        let currencyModel = CurrencyModel(managedObjectContext: event.managedObjectContext!, currencyController: currencyController)
        prepareForUse(with: event, currencyModel: currencyModel)
    }
    
    @objc(initWithEvent:andConcurrencyModel:) convenience init(event: MCSharedBill, currencyModel: CurrencyModel) {
        self.init()
        self.prepareForUse(with: event, currencyModel: currencyModel)
    }
    
    @objc var peopleFetchedResultsController: NSFetchedResultsController<MCPerson> {
        let request = MCPerson.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["emailAddress", "payments", "sharedBill", "sharedBill.mainCurrency", "payments.currency"]
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPerson.dateCreated, ascending: false)]
        request.predicate = NSPredicate(format: "ANY sharedBill = %@", event)
        let new = NSFetchedResultsController(fetchRequest: request, managedObjectContext: event.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        return new
    }
    @objc var paymentsFetchedResultsController: NSFetchedResultsController<MCPayment> {
        let request = MCPayment.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["payingPerson", "exchangeRate", "currency"]
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPayment.dateCreated, ascending: false)]
        request.predicate = NSPredicate(format: "onWhichBill = %@", event)
        let new = NSFetchedResultsController(fetchRequest: request, managedObjectContext: event.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        return new
    }
    
    private var bag = Set<AnyCancellable>()
    
    func prepareForUse(with event: MCSharedBill, currencyModel:CurrencyModel) {
        bag.removeAll()
        self.event = event
        self.currencyModel = currencyModel
        self.publisher(for: \.event!.mainCurrency, options: [.initial, .new])
            .sink { [unowned self] currency in
                if let currency, let code = currency.code {
                    self.mainCurrencyFormatter = CurrencyFormatter(currencyCode: code)
                }
            }
            .store(in: &bag)
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
    }
    
    var stringOfApproxPeoplePresent: String {
        let allNamesOfPeoplePresent: [String]
        if #available(iOS 15.0, *) {
            let sortDescriptor: SortDescriptor<MCPerson> = SortDescriptor(\.dateCreated, order: .forward)
            allNamesOfPeoplePresent = event.peoplePresent?
                .map({ $0 as! MCPerson })
                .sorted(using: sortDescriptor).map { $0.name } ?? [String]()
        } else {
            allNamesOfPeoplePresent = event.peoplePresent?
                .map({ $0 as! MCPerson })
                .sorted(by: { $0.dateCreated!.compare($1.dateCreated!) == .orderedDescending })
                .map { $0.name } ?? [String]()
        }
        
        if allNamesOfPeoplePresent.count == 0 {
            return NSLocalizedString("event_label_no_people_present", value: "No people present", comment: "A message when there are no people present inside this shared bill")
        } else if allNamesOfPeoplePresent.count == 1 {
            return allNamesOfPeoplePresent[0]
        } else if allNamesOfPeoplePresent.count == 2 {
            let localizedString = NSLocalizedString("event_label_two_people_present", value: "%1$@ and %2$@", comment: "A label showing \"person1 and person2\"")
            return String(format: localizedString, locale: Locale.current, arguments: allNamesOfPeoplePresent)
        } else if allNamesOfPeoplePresent.count >= 3 {
            let localizedString = NSLocalizedString("event_label_three_or_more_people_present", value: "%1$@, %2$@ and others", comment: "A label showing person1, person2 and other")
            return String(format: localizedString, locale: Locale.current, arguments: allNamesOfPeoplePresent)
        } else {
            fatalError("allNamesOfPeoplePresent.count can't be lower than zero")
        }
    }
    
    var totalSumOfMoneySpend: NSDecimalNumber {
        let request: NSFetchRequest<MCPayment> = MCPayment.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["payingPerson"]
        request.predicate = NSPredicate(format: "onWhichBill = %@ AND ANY peopleSharingPayment.isPersonPresent = YES", event)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPayment.dateCreated, ascending: true)]
        let context = event.managedObjectContext!
        let paymentsWithPeoplePresent: [MCPayment] = try! context.fetch(request)
        let result = paymentsWithPeoplePresent.totalSumOfMoneyInMainCurrency
        return result
    }
    
    @objc var peoplePresentOnEvent: [MCPerson] {
        let managedObjectContext = event.managedObjectContext!
        let request = MCPerson.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPerson.firstName, ascending: true)]
        request.predicate = NSPredicate(format: "ANY sharedBill = %@", event)
        do {
            let result = try managedObjectContext.fetch(request)
            return result
        } catch {
            fatalError("Error fetching people: \(error)")
        }
    }
    
    @objc var peoplePresentOnEventSortedOnFullName: [MCPerson] {
        let unsortedPeoplePresent = Array(event.peoplePresent ?? [])
        let indexedCollation = UILocalizedIndexedCollation.current()
        return indexedCollation.sortedArray(from: unsortedPeoplePresent, collationStringSelector: #selector(getter: MCPerson.fullName)) as! [MCPerson]
    }
    
    @objc var amountOfPeoplePresentOnEvent: Int {
        event.peoplePresent?.count ?? 0
    }
    
    @objc func doAllPaymentsHaveAPayer() throws -> NSNumber {
        logger.info("doAllPaymentsHaveAPayer()")
        let managedObjectContext = event.managedObjectContext!
        let request = MCPayment.fetchRequest()
        request.predicate = NSPredicate(format: "onWhichBill == %@ AND payingPerson == %@", self.event, NSNull())
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPayment.dateCreated, ascending: true)]
        do {
            let amountOfPaymentsWithoutPayers = try managedObjectContext.count(for: request)
            let result = (amountOfPaymentsWithoutPayers == 0);
            logger.debug("result: \(result)")
            return result as NSNumber
        } catch {
            logger.error("error: \(error)")
            throw error
        }
    }
    
    @objc var nextPayer: MCPerson? {
        let sortedPeople = peoplePresentOrderedByAmountPaid(inAscendingOrder: true)
        let result = sortedPeople.first
        return result
    }
    
    @objc(peoplePresentOrderedByAmountPaidInAscendingOrder:) func peoplePresentOrderedByAmountPaid(inAscendingOrder ascending: Bool) -> [MCPerson] {
        logger.trace(#function)
        let people: Set<MCPerson> = (event.peoplePresent as? Set<MCPerson>) ?? Set<MCPerson>()
        let result = people.sorted {
            let value1 = $0.totalSumPaid!
            let value2 = $1.totalSumPaid!
            return ascending ? value1.compare(value2) == .orderedAscending : value1.compare(value2) == .orderedDescending
        }
        return result
    }
    
    @objc(recentUsedForeignCurrenciesWithFetchLimit:withError:) func recentUsedForeignCurrencies(fetchLimit: UInt) throws -> [MCCurrency] {
        logger.trace(#function)
        let request = MCCurrency.fetchRequest()
        request.fetchLimit = fetchLimit > 0 ? Int(fetchLimit * 2) : 0
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCCurrency.dateCreated, ascending: false)]
        request.predicate = NSPredicate(format: "ANY payment.onWhichBill.uniqueBillId == %@ AND code != %@", event.uniqueBillId!, event.mainCurrency!.code!)
        do {
            let managedObjectContext = event.managedObjectContext!
            let unfilteredResults = try managedObjectContext.fetch(request)
            if unfilteredResults.count <= 1 {
                return unfilteredResults
            }
            
            var codes: Set<String> = []
            let uniqueResults = unfilteredResults.filter { codes.insert($0.code!).inserted }
            
            return uniqueResults.prefix(5).map { $0 }
        } catch {
            logger.error("Error fetching recentUsedCurrencies: \(error)")
            throw error
        }
    }
    
    @objc(allExchangeRatesWithError:) func allExchangeRates() throws -> [MCExchangeRate] {
        logger.info(#function)
        let request = MCExchangeRate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCExchangeRate.dateCreated, ascending: true)]
        request.predicate = NSPredicate(format: "payment.onWhichBill == %@", event)
        
        do {
            let results = try event.managedObjectContext!.fetch(request)
            return results
        } catch {
            logger.error("Error fetching all ExchangeRates on this bill: \(error)")
            throw error
        }
    }
    
    @objc func addPerson() -> MCPerson {
        let context = event.managedObjectContext!
        let person = MCPerson(context: context)
        event.payments?
            .map { $0 as! MCPayment }
            .forEach({ addPaymentPresence(on: $0, person: person, was: false) })
        person.addToSharedBill(event)
        event.addToPeoplePresent(person)
        return person
    }
    
    /// addPaymentPresence(on payment: MCPayment, person: MCPerson, was isPresent: Bool)
    /// - Parameters:
    ///   - payment: the payment on which the MCPaymentPresence object was linked.
    ///   - person: the person to which the MCPaymentPresence object was linked.`
    ///   - isPresent: whether or not the person was present during the payment
    func addPaymentPresence(on payment: MCPayment, person: MCPerson, was isPresent: Bool) {
        let context = event.managedObjectContext!
        let paymentPresence = MCPaymentPresence(context: context)
        
        paymentPresence.person = person
        person.addToSharingPayment(paymentPresence)
        
        paymentPresence.isPersonPresent = isPresent as NSNumber
        
        paymentPresence.payment = payment
        payment.addToPeopleSharingPayment(paymentPresence)
    }
    
    @objc(fetchPersonWithUniqueID:withError:) func person(with uniquePersonID: String) throws -> MCPerson {
        logger.debug("person(with uniquePersonID: String) throws")
        let request = MCPerson.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPerson.dateCreated, ascending: true)]
        request.predicate = NSPredicate(format: "ANY sharedBill = %@ AND uniquePersonId = %@", event, uniquePersonID)
        do {
            let fetchResult = try event.managedObjectContext!.fetch(request)
            guard let result = fetchResult.first else {
                throw Error.nilValue
            }
            return result
        } catch {
            logger.debug("error fetching: \(error)")
            throw error
        }
    }
    
    @objc(deletePerson:) func delete(person: MCPerson) {
        let context = event.managedObjectContext!
        person.sharingPayment?
            .map { $0 as! MCPaymentPresence }
            .forEach({ paymentPresence in
                let payment = paymentPresence.payment!
                context.delete(paymentPresence)
                let paymentModel = PaymentModel(with: payment, fromEventOf: self)
                paymentModel.recalculateAveragePeopleOweAndStore()
            })
        context.delete(person)
    }
    
    @objc func addPayment() -> MCPayment {
        logger.debug("addPayment on \(self.event)")
        let context = event.managedObjectContext!
        let payment = MCPayment(context: context)
        self.event.addToPayments(payment)
        payment.onWhichBill = self.event
        do {
            let currency = try currencyModel.generateCurrencyFromSelectedLocale()
            logger.info("Success GeneratingCurrency: \(currency)")
            payment.currency = currency
        } catch {
            logger.error("Error generating currency: \(error)")
        }
        let exchangeRate = addExchangeRate(for: payment)
        exchangeRate.source = "Payment Creation"
        let peoplePresent = self.event.peoplePresent as? Set<MCPerson>
        peoplePresent?.forEach({ person in
            let person = person as! MCPerson
            let paymentPresence = MCPaymentPresence(context: context)
            
            paymentPresence.payment = payment
            payment.addToPeopleSharingPayment(paymentPresence)
            
            paymentPresence.person = person
            person.addToSharingPayment(paymentPresence)
        })
        
        payment.exchangeRate!.toCurrency = event.mainCurrency
        event.mainCurrency!.addToExchangeRateToCurrency(payment.exchangeRate!)
        
        return payment
    }
    
    @objc(addExchangeRateForPayment:) func addExchangeRate(for payment: MCPayment) -> MCExchangeRate {
        let exchangeRate = MCExchangeRate(context: payment.managedObjectContext!)
        exchangeRate.exchangeRate = NSNumber(value: 1)
        
        payment.exchangeRate = exchangeRate
        exchangeRate.payment = payment
        
        exchangeRate.toCurrency = payment.onWhichBill!.mainCurrency
        payment.onWhichBill!.mainCurrency?.addToExchangeRateToCurrency(exchangeRate)
        
        exchangeRate.fromCurrency = payment.currency
        payment.currency?.addToExchangeRateFromCurrency(exchangeRate)
        
        return exchangeRate
    }
    
    @objc(getFirstPaymentWithoutAPayerWithError:) func getFirstPaymentWithoutAPayer() throws -> MCPayment {
        logger.debug("getFirstPaymentWithoutAPayer() throws")
        let request = MCPayment.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPayment.dateCreated, ascending: true)]
        request.predicate = NSPredicate(format: "onWhichBill = %@ AND payingPerson = %@", event, NSNull())
        do {
            let paymentsWithoutAPayer = try event.managedObjectContext!.fetch(request)
            logger.debug("paymentsWithoutAPayer: \(paymentsWithoutAPayer)")
            guard let result = paymentsWithoutAPayer.first else {
                logger.debug("No payment without a payer")
                throw Error.nilValue
            }
            return result
        } catch {
            logger.error("error fetching payments without a payer: \(error)")
            throw error
        }
    }
    
    @objc(totalSumPaidBy:withError:) func totalSumPaid(by person: MCPerson) throws -> NSDecimalNumber {
        logger.trace(#function)
        let request = MCPayment.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["payingPerson"]
        request.predicate = NSPredicate(format: "onWhichBill = %@ AND payingPerson = %@ AND ANY peopleSharingPayment.isPersonPresent = YES", event, person)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPayment.dateCreated, ascending: true)]
        do {
            let paymentsOfPerson = try event.managedObjectContext!.fetch(request)
            let result = paymentsOfPerson.totalSumOfMoneyInMainCurrency
            logger.debug("totalSumOfMoneyInMainCurrency: \(result)")
            return result
        } catch {
            logger.error("error: \(error)")
            throw error
        }
    }
    
    @objc(hasPersonPaidSomething:withError:) func hasPersonPaidSomething(by person: MCPerson) throws -> NSNumber {
        logger.trace(#function)
        do {
            let paid = try totalSumPaid(by: person)
            let comparison = paid.compare(NSDecimalNumber.zero)
            if comparison == .orderedDescending {
                return NSNumber(value: true)
            } else {
                return NSNumber(value: false)
            }
        } catch {
            logger.error("error: \(error)")
            throw error
        }
    }
    
    @objc(updateMainCurrencyFromCode:withCompletion:) func update(mainCurrencyFrom code: String, with completionHandler: ((_ error: Swift.Error?) -> Void)?) {
        do {
            let newMainCurrency = try currencyModel.generateCurrencyFromSelectedLocale()
            event.mainCurrency = newMainCurrency
            let allExchangeRates = try self.allExchangeRates()
            allExchangeRates.forEach { $0.toCurrency = newMainCurrency }
            self.updateAllExchangeRates { results, error in
                completionHandler?(error)
            }
        } catch {
            completionHandler?(error)
            return
        }
    }
    
    private func allExchangeRates(with status: MCExchangeRateStatus? = nil) throws -> [MCExchangeRate] {
        let request = MCExchangeRate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCExchangeRate.dateCreated, ascending: true)]
        let eventPredicate = NSPredicate(format: "payment.onWhichBill = %@", event)
        // When status is present add it to the predicate used.
        if let status {
            let statusPredicate = NSPredicate(format: "status != %@", status.rawValue as NSNumber)
            let predicates = [eventPredicate, statusPredicate]
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        } else {
            request.predicate = eventPredicate
        }
        let managedObjectContext = event.managedObjectContext!
        do {
            let results = try managedObjectContext.fetch(request)
            logger.info("Fetch all exchangeRates: \(results, privacy: .sensitive(mask: .hash))")
            return results
        } catch {
            logger.error("Error fetching all exchangeRates: \(error)")
            throw error
        }
    }
    
    @objc(updateAllExchangeRateswithCompletionHandler:) func updateAllExchangeRates(withCompletionHandler completionHandler: (([Any]?, Swift.Error?) -> Void)?) {
        let managedObjectContext = event.managedObjectContext!
        let updateRequest = NSBatchUpdateRequest(entity: MCExchangeRate.entity())
        updateRequest.predicate = NSPredicate(format: "payment.onWhichBill = %@", event)
        let invalidStatus = NSNumber(value: MCExchangeRateStatus.fetching.rawValue)
        updateRequest.propertiesToUpdate = ["status": invalidStatus]
        do {
            let result = try managedObjectContext.execute(updateRequest) as! NSBatchUpdateResult
            guard let exchangeRatesToFetch = result.result as? [MCExchangeRate] else {
                completionHandler?([], nil)
                return
            }
            WeAllPayStoreController.defaultStore.fetcher.fetchAll(exchangeRatesToFetch) { error in
                guard error == nil else {
                    self.logger.error("Error fetching exchange rates: \(error!)")
                    completionHandler?(nil, error)
                    return
                }
                let solutionModel = SolutionModel(eventModel: self)
                do {
                    let areAllExchangeRatesValid = try solutionModel.areAllExchangeRatesValid()
                    if areAllExchangeRatesValid.boolValue {
                        try managedObjectContext.save()
                        let results = try solutionModel.originalSolveWhoHasToPayWhoFromThisBill()
                        completionHandler?(results, nil)
                    } else {
                        completionHandler?([], nil)
                    }
                } catch {
                    self.logger.error("Not all exchangeRates are valid after fetching exchangeRates error: \(error)")
                    completionHandler?(nil, error)
                }
            }
        } catch {
            logger.error("Error update all exchange rates: \(error)")
            completionHandler?(nil, error)
            return
        }
    }
    
    @objc(updateInvalidExchangeRatesWithHandler:) func updateInvalidExchangeRates(completion: @escaping ([SolutionReturnPaymentItem]?, NSError?) -> Void) {
        // Fetch all exchangeRates that are invalid.
        let request = NSFetchRequest<MCExchangeRate>(entityName: "MCExchangeRate")
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        
        let exchangeRateValidStatus = NSNumber(value: MCExchangeRateStatus.valid.rawValue)
        request.predicate = NSPredicate(format: "payment.onWhichBill == %@ AND status != %@", event, exchangeRateValidStatus)
        
        do {
            let arrayOfInvalidExchangeRatesOfThisSharedBill = try event.managedObjectContext?.fetch(request)
            guard let invalidExchangeRates = arrayOfInvalidExchangeRatesOfThisSharedBill else {
                let fetchError = NSError(domain: "com.green.We_all_pay", code: 0, userInfo: ["reason": "Failed to fetch invalid exchange rates"])
                print("Something went wrong fetching invalid ExchangeRates: \(fetchError)")
                completion(nil, fetchError)
                return
            }
            
            for exchangeRate in invalidExchangeRates {
                exchangeRate.status = MCExchangeRateStatus.fetching.number
            }
            
            WeAllPayStoreController.defaultStore.fetcher.fetchAll(invalidExchangeRates) { error in
                if let error = error {
                    print("Something went wrong fetching exchangeRates.")
                    completion(nil, error)
                    return
                }
                
                let solutionModel = SolutionModel(eventModel: self)
                do {
                    let areAllExchangeRatesValid = try solutionModel.areAllExchangeRatesValid()
                    if areAllExchangeRatesValid.boolValue == true {
                        do {
                            try WeAllPayStoreController.defaultStore.viewContext.save()
                        } catch {
                            completion(nil, error as NSError)
                            return
                        }
                        
                        let solution = try solutionModel.originalSolveWhoHasToPayWhoFromThisBill()
                        completion(solution, nil)
                    } else {
                        let notAllExchangeRatesValidError = NSError(domain: "com.green.We_all_pay", code: 1, userInfo: ["reason": "Not all exchangeRates are valid after fetching exchangeRates"])
                        completion(nil, notAllExchangeRatesValidError)
                    }
                } catch {
                    completion(nil, error as NSError)
                }
            }
        } catch {
            print("Something went wrong fetching invalid ExchangeRates: \(error)")
            completion(nil, error as NSError)
        }
    }
    
    @objc(deletePayment:withError:) func delete(payment: MCPayment) throws {
        // It is not allowed to delete a payment belonging to another sharedBill.
        guard payment.onWhichBill == event else {
            throw Error.invalidPayment(payment)
        }
        // First delete the people presence on payment data.
        payment.peopleSharingPayment?.forEach({ paymentPresence in
            let paymentPresence = paymentPresence as! MCPaymentPresence
            event.managedObjectContext!.delete(paymentPresence)
        })
        // Then delete the payment.
        event.managedObjectContext!.delete(payment)
    }
    
    @objc func save() {
        WeAllPayStoreController.defaultStore.saveViewContext()
    }
    
    /// Resets the EventModel
    @objc func reset() {
        if !bag.isEmpty {
            bag.removeAll(keepingCapacity: true)
        }
    }
    
    // MARK: CurrencyUpdateModel
    
    var currencyCode: String {
        return self.event.mainCurrency!.code!
    }
    
    func updateCurrency(with code: String, with completion: @escaping ((Swift.Error?) -> Void)) {
        update(mainCurrencyFrom: code, with: completion)
    }
    
    var recentSelectedCurrencies: [MCCurrency] {
        return try! recentUsedForeignCurrencies(fetchLimit: 5)
    }

    // MARK: NSObject
}
