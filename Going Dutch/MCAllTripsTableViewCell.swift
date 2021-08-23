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
    
    // MARK: UITableViewCell
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
    
    override func awakeFromNib() {
        if #available(iOS 13.0, *) {
            tripLabel.backgroundColor = .clear
            totalCostLabel.backgroundColor = .clear
            peoplePresentLabel.backgroundColor = .clear
            extraLabel.backgroundColor = .clear
        }
    }
}
