//
//  MCPaymentPresenceTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 02/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

import FirebaseAnalytics

class MCPaymentPresenceTableViewCell: UITableViewCell {
    // MARK: IB Outlets
    @IBOutlet var theSwitch: UISwitch!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var personView: UIImageView!
    @IBOutlet var owesMoneyLabel: UILabel!
    
    // MARK: Properties
    var thisCellsPaymentPresence: MCPaymentPresence!
    var keyboardDismissDelegate: MCDismissKeyboardProtocol!
    
    // MARK: IB Actions
    @IBAction func switchPresence(_ sender: UISwitch) {
        FIRAnalytics.logEvent(withName: "SwitchPresence on payment", parameters: ["Presence Value": (theSwitch.isOn as NSNumber)])
        thisCellsPaymentPresence.isPersonPresent = NSNumber(value: sender.isOn)
        thisCellsPaymentPresence.payment.recalculateAveragePeopleOweAndStore()
    }
    
    @IBAction func backgroundTappedToDismissKeyboard(_ sender: AnyObject) {
        FIRAnalytics.logEvent(withName: "Background tapped to dismiss keyboard", parameters: nil)
        keyboardDismissDelegate.dismissTheKeyboard()
    }
}
