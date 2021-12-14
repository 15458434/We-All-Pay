//
//  SolutionTotalSpentTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCSolutionTotalUsedTableViewCell) final class SolutionTotalUsedTableViewCell: UITableViewCell {
    private weak var item: MCPerson?
    
    @IBOutlet var whoPaidHowMuchLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    
    @objc(prepareForUseWithPerson:fromSolutionModel:) func prepareForUse(with person: MCPerson, from model: SolutionModel) {
        self.item = person
        whoPaidHowMuchLabel.text = person.getFullName()
        let sumUsed = -(model.event.amountShouldHavePaid(by: person).doubleValue)
        moneyLabel.text = model.currencyFormatter.string(for: NSNumber(value: sumUsed))
    }
    
    // MARK: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
    }
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
