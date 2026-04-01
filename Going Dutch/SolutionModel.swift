//
//  SolutionModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/12/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit
import os
import CurrencyConverter

@objc(MCSolutionModel) final class SolutionModel: ShadowTableViewSectionModel {
    @objc(MCSolutionModelSectionTitle) enum SectionTitle: UInt {
        case whoOwesWho = 0
        case totalOwes = 1
        case totalPaid = 2
    }
    
    enum Error: Swift.Error, CustomNSError {
        case missingManagedObjectContext(MCSharedBill)
        case noPeoplePresentOnEvent(MCSharedBill)
        
        // MARK: CustomNSError
        
        static var errorDomain: String {
            "com.markcornelisse.weallpay.SolutionModelError"
        }
        
        var errorCode: Int {
            switch self {
            case .missingManagedObjectContext:
                return 100
            case .noPeoplePresentOnEvent:
                return 101
            }
        }
        
        var errorUserInfo: [String : Any] {
            var userInfo = [String: Any]()
            let description: String
            let bill: MCSharedBill
            switch self {
            case .missingManagedObjectContext(let event):
                description = "Missing managed object context."
                bill = event
            case .noPeoplePresentOnEvent(let event):
                description = "No people present on event."
                bill = event
            }
            userInfo[NSLocalizedDescriptionKey] = description
            userInfo["object"] = bill
            return userInfo
        }
    }
    
    @objc private(set) var eventModel: EventModel!
    @available(*, deprecated, message: "Use mainCurrencyFormatter on eventModel instead")
    @objc private(set) var currencyFormatter: CurrencyFormatter!
    private var logger = Logger(category: "SolutionModel")
    
    @objc(initWithEventModel:) convenience init(eventModel: EventModel) {
        self.init()
        prepareForUse(eventModel: eventModel)
    }
    
    @objc(sectionTitleForSection:) func sectionTitle(for section: SectionTitle) -> String {
        switch section {
        case .whoOwesWho:
            return NSLocalizedString("solution_view_section_title_who_owes_who", value: "Who owes whom", comment: "Section title in the solution screen that shows the title of the section that shows who owes who what how much money")
        case .totalOwes:
            return NSLocalizedString("solution_view_section_title_total_owes", value: "Total owes", comment: "Section title in the solution screen that shows the title of the section that shows who owes how much to the group")
        case .totalPaid:
            return NSLocalizedString("solution_view_section_title_total_paid", value: "Total paid", comment: "Section title in the solution screen that shows the title of the section that shows who paid how much on the entire event")
        }
    }
    
    @objc(prepareForUseWith:) func prepareForUse(eventModel: EventModel) {
        guard Thread.isMainThread else {
            fatalError()
        }
        self.eventModel = eventModel
        do {
            guard let managedObjectContext = eventModel.event.managedObjectContext else {
                throw Error.missingManagedObjectContext(eventModel.event)
            }
            
            let personFetchRequest: NSFetchRequest<MCPerson> = MCPerson.fetchRequest()
            personFetchRequest.sortDescriptors = [
                NSSortDescriptor(key: #keyPath(MCPerson.lastName), ascending: true),
                NSSortDescriptor(key: #keyPath(MCPerson.firstName), ascending: true)
            ]
            personFetchRequest.predicate = NSPredicate(format: "ANY sharedBill = %@", eventModel.event)
            let unsortedPeoplePresent = try managedObjectContext.fetch(personFetchRequest)
            
            // TODO: Figure out of MCPaymentPresences needs to be fetched or not. As between MCSharedBill and MCPerson there's a bidirectional to-many relationship.
            //            let paymentPresenceFetchRequest = MCPaymentPresence.fetchRequest()
            //            paymentPresenceFetchRequest.predicate = NSPredicate(format: "person IN %@", peoplePresent)
            //            paymentPresenceFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(MCPaymentPresence.dateModified), ascending: true)]
            //
            //            let unsortedPeoplePresent = try managedObjectContext.fetch(paymentPresenceFetchRequest)
            //            unsortedPeoplePresent.forEach { person in
            //                guard person.managedObjectContext != nil else {
            //                    logger.critical("\(person) is missing a managedObjectContext")
            //                    logger.info("data of person without managedObjectContext: \(person)")
            //                    return
            //                }
            //                logger.info("\(person) has a managedObjectContext")
            //            }
            
            let peoplePresentLocalizedSorted = (UILocalizedIndexedCollation.current().sortedArray(from: unsortedPeoplePresent, collationStringSelector: #selector(getter: MCPerson.fullName)) as! [MCPerson])
            let totalUsedModel = TotalUsedSectionItemsModel(title: sectionTitle(for: .totalOwes), items: peoplePresentLocalizedSorted)
            let totalSpentModel = TotalSpentSectionItemsModel(title: sectionTitle(for: .totalPaid), items: peoplePresentLocalizedSorted)
            self.addSection(totalUsedModel)
            self.addSection(totalSpentModel)
        } catch {
            fatalError("\(error)")
        }
    }
    
    private func managedObjectContext() throws -> NSManagedObjectContext {
        logger.trace(#function)
        guard let managedObjectContext = eventModel.event.managedObjectContext else {
            logger.error("error managedobjectContext missing from event: \(self.eventModel.event, privacy: .private)")
            throw Error.missingManagedObjectContext(eventModel.event)
        }
        return managedObjectContext
    }
    
    @objc(doesEveryoneHaveAnEmailAddress) var doesEveryoneHaveAnEmailAddress: Bool {
        let result = eventModel.event.peoplePresent?.reduce(true, { partialResult, person in
            let person = person as! MCPerson
            return person.hasEmailAddress
        }) ?? true
        return result
    }
    
    @objc(totalAmountOfPeopleWhoHavePaidWithError:) func totalAmountOfPeopleWhoHavePaid() throws -> NSNumber {
        logger.trace(#function)
        let request = MCPerson.fetchRequest()
        request.predicate = NSPredicate(format: "some payments.onWhichBill == %@", eventModel.event)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPerson.uniquePersonId, ascending: true)]
        do {
            let count = try eventModel.event.managedObjectContext!.count(for: request)
            logger.debug("totalAmountOfPeopleWhoHavePaid: \(count)")
            return count as NSNumber
        } catch {
            logger.error("totalAmountOfPeopleWhoHavePaid error: \(error)")
            throw error
        }
    }
    
    @objc(averageAmountShouldHavePaidWithError:) func averageAmountShouldHavePaid() throws -> NSDecimalNumber {
        logger.trace(#function)
        do {
            let totalAmountOfPeoplePresent = Decimal(integerLiteral: eventModel.peoplePresentOnEvent.count)
            guard totalAmountOfPeoplePresent > 0 else {
                throw Error.noPeoplePresentOnEvent(eventModel.event)
            }
            let totalSumOfMoneyOnEvent = try totalSumOfMoney().decimalValue
            let result = totalSumOfMoneyOnEvent / totalAmountOfPeoplePresent
            logger.info("result: \(result)")
            return NSDecimalNumber(decimal: result)
        } catch {
            logger.error("averageAmountShouldHavePaid error: \(error)")
            throw error
        }
    }
    
    @objc(amountShouldHavePaidBy:withError:) func amountShouldHavePaid(by person: MCPerson) throws -> NSDecimalNumber {
        logger.trace(#function)
        let request = MCPaymentPresence.fetchRequest()
        request.predicate = NSPredicate(format: "payment.onWhichBill = %@ AND person = %@ AND isPersonPresent = %@", eventModel.event, person, true as NSNumber)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPaymentPresence.person, ascending: true)]
        let managedObjectContext = try managedObjectContext()
        do {
            let paymentPresences = try managedObjectContext.fetch(request)
            let sumOfAllOwes: Decimal = paymentPresences.map({ $0.averageOweFromPaymentInMainCurrency })
                .map({ $0.decimalValue })
                .reduce(Decimal.zero, +)
            return NSDecimalNumber(decimal: sumOfAllOwes)
        } catch {
            logger.error("error fetching paymentPresences for person on this event: \(error)")
            throw error
        }
    }
    
    @objc(totalSumOfMoneyWithError:) func totalSumOfMoney() throws -> NSDecimalNumber {
        logger.trace(#function)
        let request = MCPayment.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["payingPerson"]
        request.predicate = NSPredicate(format: "onWhichBill = %@ AND ANY peopleSharingPayment.isPersonPresent = YES", eventModel.event)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(MCPayment.dateCreated), ascending: true)]
        let managedObjectContext = try managedObjectContext()
        do {
            let payments = try managedObjectContext.fetch(request)
            let result = payments.map(\.moneyInMainCurrency.decimalValue).reduce(Decimal.zero, +)
            logger.info("result: \(result)")
            return NSDecimalNumber(decimal: result)
        } catch {
            logger.error("error fetching payments: \(error) for event: \(self.eventModel.event, privacy: .private)")
            throw error
        }
    }
    
    /// Check to see if all ExchangeRates have a valid exchange rate of the currencies. Return true for when all exchange rates are valid. Returns false when there are exchange rates that are invalid.
    /// - Returns: An NSNumber holding the boolean value.
    @objc(areAllExchangeRatesValidWithError:) func areAllExchangeRatesValid() throws -> NSNumber {
        logger.trace(#function)
        let request = MCExchangeRate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(MCExchangeRate.dateCreated), ascending: true)]
        
        let exchangeRateStatus: NSNumber = NSNumber(value: MCExchangeRateStatus.valid.rawValue)
        request.predicate = NSPredicate(format: "payment.onWhichBill = %@ and status != %@", eventModel.event, exchangeRateStatus)
        let managedObjectContext = try managedObjectContext()
        do {
            let amountOfInvalidExchangeRates = try managedObjectContext.count(for: request)
            let result = (amountOfInvalidExchangeRates == 0)
            logger.info("\(#function) - Result: \(result)")
            // Must return Bool as an NSNumber for compatibility with Objective-C.
            return NSNumber(value: result)
        } catch {
            logger.error("\(#function) - Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    @objc(originalSolveWhoHasToPayWhoFromThisBillWithError:) func originalSolveWhoHasToPayWhoFromThisBill() throws -> [SolutionReturnPaymentItem] {
        logger.trace(#function)
        // Define a mutable struct for credit values to mimic the original mutable arrays
        struct Credit {
            let person: MCPerson
            let shouldPay: Decimal
            let paid: Decimal
            var left: Decimal
        }
        
        var payers: [Credit] = []
        var receivers: [Credit] = []
        var whoHasToPayWho: [SolutionReturnPaymentItem] = []
        
        let sortDescriptors = [SortDescriptor(\MCPerson.dateCreated, order: .forward)]
        let setOfPeople = eventModel.event.peoplePresent as? Set<MCPerson>
        let people = setOfPeople?.sorted(using: sortDescriptors) ?? [MCPerson]()
        
        // Update the database to the current version.
        eventModel.event.updatePaymentForSupportWithPaymentPresence()
        
        for person in people {
            let sumPaid = try eventModel.totalSumPaid(by: person).decimalValue
            let sumShould = try self.amountShouldHavePaid(by: person).decimalValue
            
            if sumPaid < sumShould {
                // This person should pay to someone.
                let leftToPay = sumShould - sumPaid
                let creditValue = Credit(person: person, shouldPay: sumShould, paid: sumPaid, left: leftToPay)
                payers.append(creditValue)
            } else if sumPaid > sumShould {
                // This person should receive from someone.
                let leftToReceive = sumPaid - sumShould
                let creditValue = Credit(person: person, shouldPay: sumShould, paid: sumPaid, left: leftToReceive)
                receivers.append(creditValue)
            } else {
                // This person has already paid enough.
                // (Original commented-out code for zero payment omitted)
            }
        }
        
        // Solve who has to pay who.
        if !payers.isEmpty {
            for i in 0..<payers.count {
                for j in 0..<receivers.count {
                    var ltp = payers[i].left
                    var ltr = receivers[j].left
                    
                    let amount: Decimal
                    if ltp >= ltr {
                        amount = ltr
                        ltp -= ltr
                        ltr = 0
                    } else {
                        amount = ltp
                        ltr -= ltp
                        ltp = 0
                    }
                    
                    // Mutate the structs in the arrays
                    payers[i].left = ltp
                    receivers[j].left = ltr
                    
                    if amount > 0 {
                        let returnPayment = SolutionReturnPaymentItem(payer: payers[i].person, money: NSDecimalNumber(decimal: amount), receiver: receivers[j].person)
                        whoHasToPayWho.append(returnPayment)
                    }
                }
            }
        }
        
        logger.debug("whoHasToPayWho: \(whoHasToPayWho)")
        return whoHasToPayWho
    }
    
    @objc(solveWithHandler:) func solve(handler: @escaping ([SolutionReturnPaymentItem]?, Swift.Error?) -> Void) {
        do {
            let areAllExchangeRatesValid = try self.areAllExchangeRatesValid()
            if areAllExchangeRatesValid.boolValue {
                let results = try self.originalSolveWhoHasToPayWhoFromThisBill()
                handler(results, nil)
            } else {
                eventModel.updateInvalidExchangeRates { results, error in
                    if let error = error {
                        handler(nil, error)
                    } else {
                        do {
                            let results = try self.originalSolveWhoHasToPayWhoFromThisBill()
                            handler(results, nil)
                        } catch {
                            self.logger.error("solveError: \(error)")
                            handler(nil, error)
                        }
                    }
                }
            }
        }
        catch {
            handler(nil, error)
            return
        }
    }
}
