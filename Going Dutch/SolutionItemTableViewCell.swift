//
//  SolutionItemTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCWhoOwesWhoTableViewCell) final class SolutionItemTableViewCell: UITableViewCell {
    private var item: SolutionReturnPaymentItem?
    
    @IBOutlet var whoOwesWhoLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    
    @objc(prepareForUseWithItem:fromModel:) func prepareForUse(with item: SolutionReturnPaymentItem, from model: SolutionModel) {
        moneyLabel.text = model.currencyFormatter!.string(for: item.money)
        
        let owesString = NSLocalizedString("solution_view_cell_who_owes_who_label", value: "%1$@ owes %2$@", comment: "In the solution view: As in Mark owes Yvette x amount of money.")
        let whoOwesWho = String.localizedStringWithFormat(owesString, item.payer!.getName(), item.receiver!.getName())
        whoOwesWhoLabel.text = whoOwesWho
        
        self.selectionStyle = .none
    }
    
    // MARK: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
    }
}
