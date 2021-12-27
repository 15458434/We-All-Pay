//
//  EventTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCEventTableViewCell) final class EventTableViewCell: UITableViewCell {
    @objc private var model: EventModel!
    
    @IBOutlet var waitingForXRatesIndicator: UIActivityIndicatorView!
    @IBOutlet var tripLabel: UILabel!
    @IBOutlet var totalCostLabel: UILabel!
    @IBOutlet var peoplePresentLabel: UILabel!
    @IBOutlet var extraLabel: UILabel!
    
    private var nameObservation: NSKeyValueObservation!
    private var peoplePresentObservation: NSKeyValueObservation!
    private var paymentsObservation: NSKeyValueObservation!
    private var dateCreatedObservation: NSKeyValueObservation!
    
    @objc func prepareForUse(with event: MCSharedBill) {
        self.model.prepareForUse(with: event)
        self.nameObservation = self.observe(\.model.event!.tripName, options: [.initial, .new], changeHandler: { mySelf, change in
            guard let newValue = change.newValue else {
                return
            }
            
            mySelf.tripLabel.text = newValue ?? NSLocalizedString("events_view_event_cell_no_event_name", value: "Unnamed event", comment: "The name of the event shown in the events list when the user didn't add an event name to the event.")
        })
        self.peoplePresentObservation = self.observe(\.model!.event!.peoplePresent, options: [.initial, .new], changeHandler: { mySelf, change in
            guard change.newValue != nil else {
                return
            }
            switch change.kind {
            case .setting:
                mySelf.peoplePresentLabel.text = mySelf.model.stringOfApproxPeoplePresent
            default:
                ()
            }
        })
        self.paymentsObservation = self.observe(\.model!.event!.payments, options: [.initial, .new], changeHandler: { mySelf, change in
            guard change.newValue != nil else {
                return
            }
            switch change.kind {
            case .setting:
                let event = mySelf.model.event!
                if event.areAllExchangeRatesValid() {
                    mySelf.totalCostLabel.isHidden = false
                    mySelf.waitingForXRatesIndicator.stopAnimating()
                    mySelf.totalCostLabel.text = mySelf.model.mainCurrencyFormatter.string(for: mySelf.model.totalSumOfMoneySpend)
                } else {
                    mySelf.totalCostLabel.text = mySelf.model.mainCurrencyFormatter.string(for: mySelf.model.totalSumOfMoneySpend)
                    mySelf.totalCostLabel.isHidden = true
                    mySelf.waitingForXRatesIndicator.startAnimating()
                }
            default:
                ()
            }
        })
        self.dateCreatedObservation = self.observe(\.model!.event!.dateModified, options: [.initial, .new], changeHandler: { mySelf, change in
            guard let newValue = change.newValue else {
                return
            }
            
            if let existingValue = newValue {
                mySelf.extraLabel.text = mySelf.model.dateFormatter.string(from: existingValue)
            } else {
                mySelf.extraLabel.text = nil
            }
            
        })
    }
    
    // MARK: UITableViewCell
    
    override func prepareForReuse() {
        nameObservation = nil
        peoplePresentObservation = nil
        paymentsObservation = nil
        dateCreatedObservation = nil
        super.prepareForReuse()
    }
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
    
    override func awakeFromNib() {
        self.model = EventModel()
        
        if #available(iOS 13.0, *) {
            tripLabel.backgroundColor = .clear
            totalCostLabel.backgroundColor = .clear
            peoplePresentLabel.backgroundColor = .clear
            extraLabel.backgroundColor = .clear
        }
    }
}
