//
//  ShowMailViewProtocol.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit
import MessageUI

@objc protocol ShowPayment {
    func show(_ payment: MCPayment)
}

protocol ShowMailViewProtocol: MailComposer {
    func showMailView(_ sender: AnyObject)
}

extension ShowMailViewProtocol where Self: UIViewController {
    func showMailView(_ sender: AnyObject) {
        debugPrint("\(self) showMailViewProtocol: \(sender)")
        
        guard MFMailComposeViewController.canSendMail() else {
            let title = NSLocalizedString("Unable to send email", comment: "Title of an alert that notifies the user the app is unable to send email.")
            let message = NSLocalizedString("Please configure your mail in Settings", comment: "Instruction in an alert to tell the user that they should check their email address for a valid configuration.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissButtonTitle = NSLocalizedString("Dismiss", comment: "Text on a button that dismisses the alert")
            let dismissAction = UIAlertAction(title: dismissButtonTitle, style: .default, handler: nil)
            alertController.addAction(dismissAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        do {
            let mailViewController = MFMailComposeViewController()
            mailViewController.setToRecipients(try mailAdresses())
            mailViewController.setSubject(try subject())
            mailViewController.setMessageBody(try mailBody(), isHTML: false)
            present(mailViewController, animated: true, completion: {
                UIApplication.shared().statusBarStyle = .lightContent
                mailViewController.setNeedsStatusBarAppearanceUpdate()
            })
        } catch MailComposerError.missingCrititcalInformationIn(let payment) {
            let title = NSLocalizedString("Data missing in payment", comment: "Alert title stating that data is missing in a payment")
            let message = NSLocalizedString("Please check the payment for missing data", comment: "Alert message suggesting the user that there is missing data on a payment.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let gotoTitle = NSLocalizedString("Go to", comment: "Go to")
            let dismissTitle = NSLocalizedString("Dismiss", comment: "Button that says dismiss")
            let gotoAction = UIAlertAction(title: gotoTitle, style: .default, handler: { [unowned self] (action) in
                guard let vc = self.presentingViewController as? ShowPayment else {
                    debugPrint("The programmer is an idiot")
                    abort()
                }

                vc.show(payment)
            })
            let dismissAction = UIAlertAction(title: dismissTitle, style: .cancel, handler: nil)
            alertController.addAction(gotoAction)
            alertController.addAction(dismissAction)
            present(alertController, animated: true, completion: nil)
        } catch MailComposerError.missingInformationIn(let payment) {
            let title = NSLocalizedString("Data missing in payment", comment: "Alert title stating that data is missing in a payment")
            let message = NSLocalizedString("Please check the payment for missing data", comment: "Alert message suggesting the user that there is missing data on a payment.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let gotoTitle = NSLocalizedString("Go to", comment: "Go to")
            let dismissTitle = NSLocalizedString("Dismiss", comment: "Button that says dismiss")
            let gotoAction = UIAlertAction(title: gotoTitle, style: .default, handler: { [unowned self] (action) in
                guard let vc = self.presentingViewController as? ShowPayment else {
                    debugPrint("The programmer is an idiot")
                    abort()
                }
                
                vc.show(payment)
            })
            let dismissAction = UIAlertAction(title: dismissTitle, style: .cancel, handler: nil)
            alertController.addAction(gotoAction)
            alertController.addAction(dismissAction)
            present(alertController, animated: true, completion: nil)
        } catch {
            let title = NSLocalizedString("Data missing in payment", comment: "Alert title stating that data is missing in a payment")
            let message = NSLocalizedString("Please check the payment for missing data", comment: "Alert message suggesting the user that there is missing data on a payment.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissTitle = NSLocalizedString("Dismiss", comment: "Button that says dismiss")
            let dismissAction = UIAlertAction(title: dismissTitle, style: .cancel, handler: nil)
            alertController.addAction(dismissAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}
