//
//  EventTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit
import Combine
import CurrencyConverter

@objc(MCEventTableViewCell) final class EventTableViewCell: UITableViewCell {
    @objc private var model: EventModel!
    
    @IBOutlet var waitingForXRatesIndicator: UIActivityIndicatorView!
    @IBOutlet var tripLabel: UILabel!
    @IBOutlet var totalCostLabel: UILabel!
    @IBOutlet var peoplePresentLabel: UILabel!
    @IBOutlet var extraLabel: UILabel!
    
    private var nameObservation: NSKeyValueObservation!
    private var peoplePresentObservation: NSKeyValueObservation!
    private var dateCreatedObservation: NSKeyValueObservation!
    
    private var bag = Set<AnyCancellable>()
    
    @objc func prepareForUse(with event: MCSharedBill) {
        self.model.prepareForUse(with: event, currencyModel: CurrencyModel(managedObjectContext: event.managedObjectContext!, currencyController: CurrencyController()))
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
        let paymentsPublisher = self.publisher(for: \.model!.event!.payments, options: [.initial, .new])
        self.publisher(for: \.model!.mainCurrencyFormatter, options: [.initial, .new])
            .combineLatest(paymentsPublisher)
            .sink { [unowned self] mainCurrency, payments in
                let totalAmountOfMoneyInMainCurrency = payments?.totalSumOfMoneyInMainCurrency
                let event = self.model.event!
                if event.areAllExchangeRatesValid() {
                    self.totalCostLabel.isHidden = false
                    self.waitingForXRatesIndicator.stopAnimating()
                    self.totalCostLabel.text = self.model.mainCurrencyFormatter.string(for: totalAmountOfMoneyInMainCurrency)
                } else {
                    self.totalCostLabel.text = self.model.mainCurrencyFormatter.string(for: totalAmountOfMoneyInMainCurrency)
                    self.totalCostLabel.isHidden = true
                    self.waitingForXRatesIndicator.startAnimating()
                }
            }.store(in: &bag)
    }
    
    // MARK: UITableViewCell
    
    override func prepareForReuse() {
        nameObservation = nil
        peoplePresentObservation = nil
        dateCreatedObservation = nil
        bag.removeAll(keepingCapacity: true)
        model.reset()
        super.prepareForReuse()
    }
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
    
    override func awakeFromNib() {
        self.model = EventModel()
        
        tripLabel.backgroundColor = .clear
        totalCostLabel.backgroundColor = .clear
        peoplePresentLabel.backgroundColor = .clear
        extraLabel.backgroundColor = .clear
    }
}
