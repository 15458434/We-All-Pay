//
//  MCPaymentPresenceTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 02/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit
import Combine

import FirebaseAnalytics

final class MCPaymentPresenceTableViewCell: UITableViewCell {
    // MARK: IB Outlets
    @IBOutlet weak var theSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var personView: UIImageView!
    @IBOutlet weak var owesMoneyLabel: UILabel!
    
    // MARK: Properties
    private weak var model: PaymentModel!
    private weak var paymentPresence: MCPaymentPresence!
    var keyboardDismissDelegate: MCDismissKeyboardProtocol!
    
    // MARK: IB Actions
    @IBAction func switchPresence(_ sender: UISwitch) {
        model.update(paymentPresence: paymentPresence, to: sender.isOn)
        model.recalculateAveragePeopleOweAndStore()
    }
    
    @IBAction func backgroundTappedToDismissKeyboard(_ sender: AnyObject) {
        keyboardDismissDelegate.dismissTheKeyboard()
    }
    
    private var bag = Set<AnyCancellable>()
    
    func update(model: PaymentModel, and paymentPresence: MCPaymentPresence) {
        self.model = model
        self.paymentPresence = paymentPresence
        nameLabel.text = paymentPresence.person!.fullName
        personView.image = paymentPresence.person!.thumbnail
        theSwitch.setOn(paymentPresence.isPersonPresent!.boolValue, animated: false)

        self.paymentPresence.publisher(for: \MCPaymentPresence.averageOweFromPayment, options: [.initial, .new]).map({ averageOweFromPayment in
            let cf: CurrencyFormatter = CurrencyFormatter(currencyCode: paymentPresence.payment!.currency!.code!)
            let valueToShow = NSNumber(value: -averageOweFromPayment!.doubleValue)
            return cf.string(for: averageOweFromPayment)
        }).assign(to: \UILabel.text, on: self.owesMoneyLabel)
            .store(in: &bag)
    }
    
    // MARK: UITableViewCell
    
    override func prepareForReuse() {
        bag.removeAll(keepingCapacity: true)
    }
    
    // MARK: NSCoding
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
