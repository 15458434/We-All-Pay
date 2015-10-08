//
//  MCPaymentPresenceTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 02/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

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
    @IBAction func switchPresence(sender: UISwitch) {
        thisCellsPaymentPresence.isPersonPresent = NSNumber(bool: sender.on)
        thisCellsPaymentPresence.payment.recalculateAveragePeopleOweAndStore()
    }
    
    @IBAction func backgroundTappedToDismissKeyboard(sender: AnyObject) {
        keyboardDismissDelegate.dismissTheKeyboard()
    }
}