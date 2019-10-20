//
//  SolutionTableViewController_iPad.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit
import MessageUI

import FirebaseAnalytics

class SolutionTableViewController_iPad: MCSolutionTableViewController, MFMailComposeViewControllerDelegate, ThisEvent, ShowMailViewProtocol {
    
    // MARK: New in this class
    override func openMailView(_ sender: Any!) {
        Analytics.logEvent("openMailView", parameters: nil)
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

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            Analytics.logEvent("MailComposeViewController cancel", parameters: nil)
            self.presentedViewController!.dismiss(animated: true, completion: nil)
        case .sent:
            Analytics.logEvent("MailComposeViewController sent", parameters: nil)
            self.showRateMeIfNecessary()
            self.presentedViewController!.dismiss(animated: true, completion: {
                self.event.hasTheMailBeenSent = NSNumber(booleanLiteral: true)
                MCWeAllPayStoreController.defaultStore().saveMainThreadContext()
            })
        case .failed:
            Analytics.logEvent("MailComposeViewController failed", parameters: nil)
            self.presentedViewController!.dismiss(animated: true, completion: nil)
        case .saved:
            Analytics.logEvent("MailComposeViewControler saved", parameters: nil)
            self.presentedViewController!.dismiss(animated: true, completion: nil)
        @unknown default:
            fatalError("Unknown value for MFMailComposeResult")
        }
    }
}
