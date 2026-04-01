//
//  SolutionTotalSpentTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/12/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCSolutionTotalSpentTableViewCell) final class SolutionTotalSpentTableViewCell: UITableViewCell {
    private weak var item: MCPerson!
    private weak var model: SolutionModel!
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var moneyLabel: UILabel!
    
    @objc(prepareForUseWithPerson:fromSolutionModel:) func prepareForUse(with person: MCPerson, from model: SolutionModel) {
        self.item = person
        self.model = model
        nameLabel.text = person.fullName
        moneyLabel.text = model.eventModel.mainCurrencyFormatter.string(for: person.totalSumPaid)
    }
    
    @objc(prepareForUseWithModel:) func prepareForUse(with model: SolutionModel) {
        self.model = model
        nameLabel.text = NSLocalizedString("solution_view_cell_label_total_spent", value: "Total spent:", comment: "In the solution view: a label before the total amount of money spent on the entire event.")
        moneyLabel.text = model.eventModel.mainCurrencyFormatter.string(for: try! model.totalSumOfMoney())
    }
    
    // MARK: UITableViewCell
    
    override func prepareForReuse() {
        self.item = nil
        self.model = nil
        super.prepareForReuse()
    }
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
