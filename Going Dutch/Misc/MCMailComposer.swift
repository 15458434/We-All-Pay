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
        let sortDescriptorArray = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        let allPeople = tonightsBill.peoplePresent.sortedArrayUsingDescriptors(sortDescriptorArray) as [MCPerson]
        var listOfMailAddresses = [String]()
        for person in allPeople {
            listOfMailAddresses.append(person.defaultEmailAddress()!)
        }
        return listOfMailAddresses
    }
    
    func getSubject() -> String! {
        return String.localizedStringWithFormat(NSLocalizedString("EMAIL_SUBJECT", comment: "Bill overview of our trip to %1$@"), self.tonightsBill.tripName)
    }
    
    func getMailBody() -> String! {
        let solution = tonightsBill.solveWhoHasToPayWhoFromThisBill() as [MCReturnPayment]
        let sortDescriptorOnDateCreated = NSSortDescriptor(key: "dateCreated", ascending: true)
        let allPayments = tonightsBill.payments.sortedArrayUsingDescriptors([sortDescriptorOnDateCreated]) as [MCPayment]
        let allPeople = tonightsBill.peoplePresent.sortedArrayUsingDescriptors([sortDescriptorOnDateCreated]) as [MCPerson]
        
        var mailBody = String()
        mailBody += "https://itunes.apple.com/us/app/we-all-pay/id642135963?mt=8&uo=4\n\n"
        
        mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_DEAR", comment: "Dear %1$@,"), self.tonightsBill.stringOfApproxPeoplePresent())
        mailBody += "\n\n"
        mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_INTRO", comment: "From a total of \"$ 20,45\", which was spend on our last trip to \"Movies\". We all have to pay an equal share of \"$6,82\"."), self.tonightsBill.totalSumOfMoneyOfThisSharedBillAsCurrencyString(), self.tonightsBill.tripName, self.tonightsBill.amountPeopleShouldHavePaidAsCurrencyString())
        mailBody += "\n\n"
        
        switch tonightsBill.totalAmountOfPeopleWhoHavePaid() {
        case 1:
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_ONE_PERSON_HAS_PAID", comment: "The person who has payed %1$@"), allPayments.first!.payingPerson!.getName()!)
        case let totalAmountOfPeoplewhoHavePaid where totalAmountOfPeoplewhoHavePaid > 1:
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_MULTIPLE_PEOPLE_HAVE_PAID", comment: "The people who have paid are"))
        default:
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_NOBODY_HAS_PAID", comment: "The message that nobody has paid so far"))
        }
        mailBody += "\n"
        
        for payment in allPayments {
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_WHO_HAS_PAID", comment: "%1$@ has paid %2$@ for %3$@."), payment.payingPerson!.getName()!, tonightsBill.mainCurrency!.numberFormatter().stringFromNumber(payment.moneyInMainCurrency())!, payment.fullDescriptionOfPayment()!)
            mailBody += "\n"
        }
        mailBody += "\n"
        
        mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_AVERAGE_OF_USE_SENTENCE", comment: "The amount of money we used:"))
        mailBody += "\n"
        for person in allPeople {
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_AMOUNT_USED", comment: "%1$@ used %2$@ in total."), person.getName(), tonightsBill.amountShouldHavePaidAsCurrencyStringBy(person))
            mailBody += "\n"
        }
        mailBody += "\n"
        
        mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_I_SUGGEST", comment: "I suggest the following solution."))
        mailBody += "\n"
        
        for returnPayment in solution {
            mailBody += String.localizedStringWithFormat(NSLocalizedString("EMAIL_OWES", comment: "%1$@ pays %2$@ to %3$@"), returnPayment.payer.getFullName(), tonightsBill.mainCurrency.numberFormatter().stringFromNumber(returnPayment.money)!, returnPayment.receiver.getFullName())
            mailBody += "\n"
        }
        mailBody += "\n"
        
        mailBody += NSLocalizedString("EMAIL_FINAL_SENTENCE", comment: "If you have any remarks please let me know.")
        mailBody += "\n"
        
        return mailBody
    }
}