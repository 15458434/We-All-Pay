//
//  MCPaymentPresenceTableViewCell_iPhone.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

class MCPaymentPresenceTableViewCell_iPhone: UITableViewCell {
    @IBOutlet var personView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var isPresentSwitch: UISwitch!
    @IBOutlet var owesLabel: UILabel!
    var thisCellsPaymentPresence: MCPaymentPresence?
    
    func presenceIsSwitched(_ sender: AnyObject) {
        thisCellsPaymentPresence!.isPersonPresent = NSNumber(value: isPresentSwitch.isOn)
        thisCellsPaymentPresence!.payment.recalculateAveragePeopleOweAndStore()
    }
}
