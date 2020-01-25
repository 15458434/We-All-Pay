//
//  MCAllTripsTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

final class MCAllTripsTableViewCell: UITableViewCell {
    @IBOutlet var waitingForXRatesIndicator: UIActivityIndicatorView!
    @IBOutlet var tripLabel: UILabel!
    @IBOutlet var totalCostLabel: UILabel!
    @IBOutlet var peoplePresentLabel: UILabel!
    @IBOutlet var extraLabel: UILabel!
}
