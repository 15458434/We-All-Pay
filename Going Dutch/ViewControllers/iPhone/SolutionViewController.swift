//
//  ReturnPaymentViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit
import MessageUI

import FirebaseAnalytics

class SolutionViewController: MCReturnPaymentViewController, MFMailComposeViewControllerDelegate, ThisEvent, ShowMailViewProtocol {
    
    // MARK: New in this class
    override func openMailView(_ sender: Any!) {
        FIRAnalytics.logEvent(withName: "openMailView", parameters: nil)
        self.showMailView(sender as AnyObject)
    }
    
    // MARK: ThisEvent
    var event: MCSharedBill! {
        set {
            tonightsBill = newValue
        }
        get {
            return tonightsBill
        }
    }
    
    // MARK: ShowMailViewProtocol
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            FIRAnalytics.logEvent(withName: "MailComposeViewController cancel", parameters: nil)
            self.presentedViewController!.dismiss(animated: true, completion: nil)
        case .sent:
            FIRAnalytics.logEvent(withName: "MailComposeViewController sent", parameters: nil)
            self.showRateMeIfNecessary()
            self.presentedViewController!.dismiss(animated: true, completion: {
                self.event.hasTheMailBeenSent = NSNumber(booleanLiteral: true)
                MCWeAllPayStoreController.defaultStore().saveMainThreadContext()
            })
        case .failed:
            FIRAnalytics.logEvent(withName: "MailComposeViewController failed", parameters: nil)
            self.presentedViewController!.dismiss(animated: true, completion: nil)
        case .saved:
            FIRAnalytics.logEvent(withName: "MailComposeViewControler saved", parameters: nil)
            self.presentedViewController!.dismiss(animated: true, completion: nil)
        }
    }
}
