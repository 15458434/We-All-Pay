//
//  MCPersonTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

class MCPersonTableViewCell: UITableViewCell {
    @IBOutlet var fetchingExchangeRateIndicator: UIActivityIndicatorView!
    @IBOutlet var personImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var totalSpent: UILabel!
}
