//
//  NotificationTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    private var model: NotificationsItemProtocol!
    
    @IBOutlet weak var senderView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    func update(model: NotificationsItemProtocol) {
        self.senderView.image = model.image
        self.titleLabel.text = model.title
        self.subTitleLabel.text = model.subTitle
    }
    
    // MARK: UITableViewCell
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
