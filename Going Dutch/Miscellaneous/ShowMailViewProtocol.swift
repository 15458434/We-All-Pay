//
//  ShowMailViewProtocol.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit
import MessageUI

import FirebaseAnalytics

@objc protocol ShowPayment {
    func show(_ payment: MCPayment)
}

protocol ShowMailViewProtocol: MailComposer {
    func showMailView(_ sender: AnyObject)
}

extension ShowMailViewProtocol where Self: UIViewController, Self: MFMailComposeViewControllerDelegate {
    func showMailView(_ sender: AnyObject) {
        func showDataMissingAlert(for payment: MCPayment? = nil) {
            let title = NSLocalizedString("solution_view_alert_title_data_missing_in_payment", value: "Data missing in payment", comment: "Alert title stating that data is missing in a payment")
            let message = NSLocalizedString("solution_view_alert_message_data_missing_in_payment", value: "Please check the payment for missing data", comment: "Alert message suggesting the user that there is missing data on a payment.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            // If payment is present add a goto button so the user can instantly navigate there.
            if let payment = payment {
                let gotoTitle = NSLocalizedString("solution_view_alert_action_data_missing_in_payment_go_to", value: "Go to", comment: "An action button in an alert that allows for instant navigation to a payment with missing data.")
                let gotoAction = UIAlertAction(title: gotoTitle, style: .default, handler: { [unowned self] (action) in
                    let viewControllerThatCanShowPayment = self.presentingViewController as! ShowPayment
                    viewControllerThatCanShowPayment.show(payment)
                })
                alertController.addAction(gotoAction)
            }
            let dismissTitle = NSLocalizedString("solution_view_alert_action_data_missing_in_payment_dimiss", value: "Dismiss", comment: "Button that says dismiss")
            let dismissAction = UIAlertAction(title: dismissTitle, style: .cancel, handler: nil)
            alertController.addAction(dismissAction)
            present(alertController, animated: true, completion: nil)
        }
        
        guard MFMailComposeViewController.canSendMail() else {
            let title = NSLocalizedString("solution_view_alert_title_cannot_send_mail", value: "Unable to send email", comment: "Title of an alert that notifies the user the app is unable to send email.")
            let message = NSLocalizedString("solution_view_alert_message_cannot_send_mail", value: "Please configure your mail in Settings", comment: "Instruction in an alert to tell the user that they should check their email address for a valid configuration.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissButtonTitle = NSLocalizedString("solution_view_alert_action_cannot_send_email_dismiss", value: "Dismiss", comment: "Text on a button that dismisses the alert")
            let dismissAction = UIAlertAction(title: dismissButtonTitle, style: .default, handler: nil)
            alertController.addAction(dismissAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        do {
            let mailViewController = MailComposeViewController()
            mailViewController.mailComposeDelegate = self
            mailViewController.setToRecipients(try mailAdresses())
            mailViewController.setSubject(try subject())
            mailViewController.setMessageBody(try mailBody(), isHTML: false)
            present(mailViewController, animated: true)
        } catch MailComposerError.missingCrititcalInformationIn(let payment) {
            showDataMissingAlert(for: payment)
        } catch MailComposerError.missingInformationIn(let payment) {
            showDataMissingAlert(for: payment)
        } catch {
            showDataMissingAlert()
        }
    }
}
