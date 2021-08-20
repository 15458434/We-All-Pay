//
//  MCPersonTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

final class MCPersonTableViewCell: UITableViewCell {
    @IBOutlet var fetchingExchangeRateIndicator: UIActivityIndicatorView!
    @IBOutlet var personImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var totalSpent: UILabel!
    
    // MARK: UITableViewCell
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
    
    #if TARGET_INTERFACE_BUILDER
    override class func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.nameLabel.text = "Merit Koelink"
        self.emailLabel.text = "merit@gitaarspelen.nl"
        self.totalSpent.text = "$67,42"
    }
    #endif

}
