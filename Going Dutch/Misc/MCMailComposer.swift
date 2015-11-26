//
//  MCMailComposer.swift
//  We all pay
//
//  Created by Mark Cornelisse on 04/02/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc(MCMailComposer)
class MCMailComposer: NSObject {
    var tonightsBill: MCSharedBill
    var isHTML: Bool = false
    
    @objc(initWithTonightsBill:)
    init(tonightsBill: MCSharedBill!) {
        self.tonightsBill = tonightsBill!
        super.init()
    }
    
    func getMailAddresses() -> [AnyObject]! {
        let allPeople = Array(tonightsBill.peoplePresent) as! [MCPerson]
        var listOfMailAddresses = [String]()
        for person in allPeople {
            if let emailAddress = person.defaultEmailAddress() {
                listOfMailAddresses.append(emailAddress)
            }
        }
        return listOfMailAddresses
    }
    
    func getSubject() -> String! {
        if let tripName = self.tonightsBill.tripName {
            return String.localizedStringWithFormat(NSLocalizedString("EMAIL_SUBJECT_WITH_TRIPNAME", comment: "Bill overview of our trip to %1$@"), tripName)
        } else {
            return NSLocalizedString("EMAIL_SUBJECT", comment: "Bill overview of our event.")
        }
    }
    
    func getMailBody() -> String! {
        let mainCurrencyFormatter = CurrencyFormatter()
        let localCurrencyFormatter = CurrencyFormatter()
        mainCurrencyFormatter.currencyCode = tonightsBill.mainCurrency.code
        
        let solution = tonightsBill.solveWhoHasToPayWhoFromThisBill() as! [ReturnPayment]
//        let sortDescriptorOnDateCreated = NSSortDescriptor(key: "dateCreated", ascending: true)
        let allPayments = Array(tonightsBill.payments) as! [MCPayment]
        let allPeople = Array(tonightsBill.peoplePresent) as! [MCPerson]
        
        var mailBody = String()
        mailBody += "https://itunes.apple.com/us/app/we-all-pay/id642135963?mt=8&uo=4\n\n"
        
        mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_DEAR", comment: "Dear %1$@,"), self.tonightsBill.stringOfApproxPeoplePresent())
        mailBody += "\n\n"
        
        if let tripName = self.tonightsBill.tripName {
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_INTRO_WITH_TRIPNAME", comment: "Here you go. The full overview of the %1$@ which we spend on our last event %2$@. We spent an average of %3$@ a person. You can find more of the details below."), mainCurrencyFormatter.stringForObjectValue(tonightsBill.totalSumOfMoneyOfThisSharedBill())!, tripName, mainCurrencyFormatter.stringForObjectValue(tonightsBill.amountPeopleShouldHavePaid())!)
        } else {
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_INTRO", comment: "Here you go. The full overview of the %1$@ which we spend on our last event. We spent an average of %2$@ a person. You can find more of the details below."), mainCurrencyFormatter.stringForObjectValue(tonightsBill.totalSumOfMoneyOfThisSharedBill())!, mainCurrencyFormatter.stringForObjectValue(tonightsBill.amountPeopleShouldHavePaid())!)
        }
        mailBody += "\n\n"
        
        switch tonightsBill.totalAmountOfPeopleWhoHavePaid() {
        case 1:
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_ONE_PERSON_HAS_PAID", comment: "The person who has payed %1$@"), allPayments.first!.payingPerson!.getFullName()!)
        case let totalAmountOfPeoplewhoHavePaid where totalAmountOfPeoplewhoHavePaid > 1:
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_MULTIPLE_PEOPLE_HAVE_PAID", comment: "The people who have paid are"))
        default:
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_NOBODY_HAS_PAID", comment: "The message that nobody has paid so far"))
        }
        mailBody += "\n"
        
        for payment in allPayments {
            if payment.exchangeRate.exchangeRate.doubleValue == 1.0 {
                mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_WHO_HAS_PAID", comment: "%1$@ has paid %2$@ for %3$@."), payment.payingPerson!.getFullName()!, mainCurrencyFormatter.stringForObjectValue(payment.moneyInMainCurrency())!, payment.fullDescriptionOfPayment()!)
            } else {
                localCurrencyFormatter.currencyCode = payment.currency.code
                mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_WHO_HAS_PAID_INTERNATIONAL", comment: "%1$@ has paid %2$@(%3$@) for %4$@."), payment.payingPerson!.getFullName()!, mainCurrencyFormatter.stringForObjectValue(payment.moneyInMainCurrency())!, localCurrencyFormatter.stringForObjectValue(payment.money)!, payment.fullDescriptionOfPayment()!)
            }
            mailBody += "\n"
        }
        mailBody += "\n"
        
        mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_AVERAGE_OF_USE_SENTENCE", comment: "The amount of money we used:"))
        mailBody += "\n"
        for person in allPeople {
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_AMOUNT_USED", comment: "%1$@ used %2$@ in total."), person.getFullName(), mainCurrencyFormatter.stringForObjectValue(tonightsBill.amountShouldHavePaidBy(person))!)
            mailBody += "\n"
        }
        mailBody += "\n"
        
        mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_I_SUGGEST", comment: "I suggest the following solution."))
        mailBody += "\n"
        
        for returnPayment in solution {
            let payerFullName: String = returnPayment.payer?.getFullName() ?? ""
            let moneyNumber = returnPayment.money ?? NSNumber(double: 0.0)
            let moneyString: String = mainCurrencyFormatter.stringForObjectValue(moneyNumber)!
            let receiverFullName: String = returnPayment.receiver?.getFullName() ?? ""
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_OWES", comment: "%1$@ pays %2$@ to %3$@"), payerFullName, moneyString, receiverFullName)
            mailBody += "\n"
        }
        mailBody += "\n"
        
        mailBody += NSLocalizedString("EMAIL_FINAL_SENTENCE", comment: "If you have any remarks please let me know.")
        mailBody += "\n"
        
        return mailBody
    }
}