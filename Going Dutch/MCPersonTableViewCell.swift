//
//  MCPersonTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit
import Combine

@objc(MCPersonTableViewCell)
final class PersonTableViewCell: UITableViewCell {
    @objc private(set) weak var eventModel: EventModel!
    @objc private(set) var personModel: PersonModel!
    
    @IBOutlet var fetchingExchangeRateIndicator: UIActivityIndicatorView!
    @IBOutlet var personImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var totalSpent: UILabel!
    
    private var bag = Set<AnyCancellable>()
    
    @objc(updateWithEventModel:andPerson:) func update(eventModel: EventModel, person: MCPerson) {
        self.eventModel = eventModel
        personModel.prepareForUse(withPerson: person)
        self.personImage.image = personModel.person.thumbnail
        self.nameLabel.text = personModel.fullName
        self.emailLabel.text = personModel.defaultEmailaddress?.emailAddress
        
        if personModel.areAllExchangeRatesPresent {
            fetchingExchangeRateIndicator.startAnimating()
            totalSpent.isHidden = true
        } else {
            self.fetchingExchangeRateIndicator.stopAnimating()
            totalSpent.isHidden = false
            
            let cf = eventModel.mainCurrencyFormatter!
            totalSpent.text = cf.string(for: personModel.person.totalSumPaid)
        }
    }
    
    // MARK: UITableViewCell
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
    
    override func awakeFromNib() {
        self.personModel = PersonModel()
    }
    
    #if TARGET_INTERFACE_BUILDER
    override class func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.nameLabel.text = "Merit Koelink"
        self.emailLabel.text = "merit@gitaarspelen.nl"
        self.totalSpent.text = "$67,42"
    }
    #endif

}
