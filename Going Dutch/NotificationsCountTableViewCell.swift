//
//  NotificationsCountTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

class NotificationsCountTableViewCell: UITableViewCell {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var countView: UnreadNotificationsCountView!
    
    func update(count: Int) {
        countView.count = count
    }
    
    // MARK: UITableViewCell
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
