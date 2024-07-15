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
    
    @IBOutlet weak var whoPaidHowMuchLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    @objc(prepareForUseWithPerson:fromSolutionModel:) func prepareForUse(with person: MCPerson, from model: SolutionModel) {
        self.item = person
        whoPaidHowMuchLabel.text = person.fullName
        let sumUsed = -(model.event.amountShouldHavePaid(by: person).doubleValue)
        moneyLabel.text = model.currencyFormatter.string(for: NSNumber(value: sumUsed))
    }
    
    // MARK: UITableViewCell
    
    override func prepareForReuse() {
        item = nil
        super.prepareForReuse()
    }
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
