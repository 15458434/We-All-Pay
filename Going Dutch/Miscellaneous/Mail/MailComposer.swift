//
//  MCMailComposer.swift
//  We all pay
//
//  Created by Mark Cornelisse on 04/02/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

protocol MailComposer {
    func mailAdresses() throws -> [String]
    func subject() throws -> String
    func mailBody() throws -> String
}

enum MailComposerError: Error {
    case missingCrititcalInformationIn(payment: MCPayment)
    case missingInformationIn(payment: MCPayment)
}

extension MailComposer where Self: ThisEventReadOnly {
    func mailAdresses() throws -> [String] {
        let allPeople = Array(event.peoplePresent ?? Set<MCPerson>())
        var listOfMailAddresses = [String]()
        for person in allPeople {
            if let emailAddress = person.defaultEmailAddress() {
                listOfMailAddresses.append(emailAddress)
            }
        }
        return listOfMailAddresses
    }
    
    func subject() throws -> String {
        if let tripName = self.event.tripName {
            return String.localizedStringWithFormat(NSLocalizedString("solution_email_subject", value: "Expenses overview of our event %1$@", comment: "Bill overview of our trip to %1$@"), tripName)
        } else {
            return NSLocalizedString("solution_email_subject_no_event_name", value: "Expenses overview of our event.", comment: "Bill overview of our event.")
        }
    }
    
    func mailBody() throws -> String {
        // Too many crashes happen here. Some logging should show where it goes wrong.
        Crashlytics.crashlytics().log("************** start mail body **************")
        Crashlytics.crashlytics().log("\(String(describing: event))")
        Crashlytics.crashlytics().log("  \(String(describing: event.mainCurrency))")
        event.peoplePresent?.enumerated().forEach { (index, person) in
            Crashlytics.crashlytics().log("  index \(index): \(person)")
            person.emailAddress?.enumerated().forEach { (index, emailAddress) in
                Crashlytics.crashlytics().log("    index \(index): \(emailAddress)")
            }
//            person.sharingPayment?.enumerated().forEach { (index, presence) in
//                Crashlytics.crashlytics().log("    index \(index): \(presence)")
//            }
        }
        event.payments?.enumerated().forEach { (index, payment) in
            Crashlytics.crashlytics().log("  index \(index): \(payment)")
        }
        Crashlytics.crashlytics().log("*************** end mail body ***************")
        
        let mainCurrencyFormatter = CurrencyFormatter()
        let localCurrencyFormatter = CurrencyFormatter()
        mainCurrencyFormatter.currencyCode = event.mainCurrency!.code
        let model = EventModel(andPrepareWith: event)
        
        let solution = event.solveWhoHasToPayWhoFromThisBill() as! [SolutionReturnPaymentItem]
//        let sortDescriptorOnDateCreated = NSSortDescriptor(key: "dateCreated", ascending: true)
        let allPayments = Array(event.payments ?? Set<MCPayment>())
        let allPeople = Array(event.peoplePresent ?? Set<MCPerson>())
        
        var mailBody = String()
        mailBody += "https://itunes.apple.com/us/app/we-all-pay/id642135963?mt=8&uo=4\n\n"
        
        mailBody += String.localizedStringWithFormat(NSLocalizedString("solution_mail_header", value: "Dear %1$@,", comment: "Dear %1$@,"), model.stringOfApproxPeoplePresent)
        mailBody += "\n\n"
        
        if let tripName = self.event.tripName {
            mailBody += String.localizedStringWithFormat(NSLocalizedString("solution_mail_body_1a", value: "Here you go. The full overview of the %1$@ which we spend on our last event %2$@. We spent an average of %3$@ a person. You can find more details below.", comment: "Here you go. The full overview of the %1$@ which we spend on our last event %2$@. We spent an average of %3$@ a person. You can find more of the details below."), mainCurrencyFormatter.string(for: event.totalSumOfMoneyOfThisSharedBill())!, tripName, mainCurrencyFormatter.string(for: event.amountPeopleShouldHavePaid())!)
        } else {
            mailBody += String.localizedStringWithFormat(NSLocalizedString("solution_mail_body_1b", value: "Here you go. The full overview of the %1$@ which we spend on our last event. We spent an average of %2$@ a person. You can find more of the details below.", comment: "Here you go. The full overview of the %1$@ which we spend on our last event. We spent an average of %2$@ a person. You can find more of the details below."), mainCurrencyFormatter.string(for: event.totalSumOfMoneyOfThisSharedBill())!, mainCurrencyFormatter.string(for: event.amountPeopleShouldHavePaid())!)
        }
        mailBody += "\n\n"
        
        let pluralString = NSLocalizedString("solution_view_email_result_total_sum_paid_by", comment: "")
        mailBody += String.localizedStringWithFormat(pluralString, event.totalAmountOfPeopleWhoHavePaid())
        mailBody += "\n"
        
        for payment in allPayments {
            guard payment.payingPerson != nil else {
                throw MailComposerError.missingCrititcalInformationIn(payment: payment)
            }
            let fullname = payment.payingPerson!.fullName
            let moneyInMainCurrency = mainCurrencyFormatter.string(for: payment.moneyInMainCurrency)!
            let paymentDescription = payment.fullDescriptionOfPayment()
            if payment.exchangeRate!.exchangeRate!.doubleValue == 1.0 {
                mailBody += String.localizedStringWithFormat(NSLocalizedString("solution_mail_body_2a", value: "%1$@ paid %2$@ for %3$@.", comment: "%1$@ has paid %2$@ for %3$@."), fullname, moneyInMainCurrency, paymentDescription)
            } else {
                localCurrencyFormatter.currencyCode = payment.currency!.code!
                let localCurrency = localCurrencyFormatter.string(for: payment.money!)!
                mailBody += String.localizedStringWithFormat(NSLocalizedString("solution_mail_body_2b", value: "%1$@ has paid %2$@(%3$@) for %4$@", comment: "%1$@ has paid %2$@(%3$@) for %4$@."), fullname, moneyInMainCurrency, localCurrency, paymentDescription)
            }
            
            mailBody += "\n"
        }
        mailBody += "\n"
        
        mailBody += String.localizedStringWithFormat(NSLocalizedString("solution_mail_body_3", value: "We each used these amounts:", comment: "The amount of money we used:"))
        mailBody += "\n"
        for person in allPeople {
            mailBody += String.localizedStringWithFormat(NSLocalizedString("solution_mail_body_4", value: "%1$@ used %2$@ in total.", comment: "%1$@ used %2$@ in total."), person.fullName, mainCurrencyFormatter.string(for: event.amountShouldHavePaid(by: person))!)
            mailBody += "\n"
        }
        mailBody += "\n"
        
        mailBody += String.localizedStringWithFormat(NSLocalizedString("solution_mail_body_5", value: "Based on all of this, I suggest the following solution:", comment: "I suggest the following solution."))
        mailBody += "\n"
        
        for returnPayment in solution {
            let payerFullName: String = returnPayment.payer?.fullName ?? ""
            let moneyNumber = returnPayment.money ?? NSNumber(value: 0.0)
            let moneyString: String = mainCurrencyFormatter.string(for: moneyNumber)!
            let receiverFullName: String = returnPayment.receiver?.fullName ?? ""
            mailBody += String.localizedStringWithFormat(NSLocalizedString("solution_mail_body_6", value: "%1$@ pays %2$@ to %3$@.", comment: "%1$@ pays %2$@ to %3$@"), payerFullName, moneyString, receiverFullName)
            mailBody += "\n"
        }
        mailBody += "\n"
        
        mailBody += NSLocalizedString("solution_mail_body_7", value: "If you have any remarks, please let me know.", comment: "If you have any remarks please let me know.")
        mailBody += "\n"
        
        return mailBody
    }
}
