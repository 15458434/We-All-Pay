//
//  NotificationTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    @objc private weak var model: NotificationsItemProtocol!
    
    @IBOutlet weak var senderView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var isReadIndicator: NotificationReadIndicator!
    
    private var isReadObservation: NSKeyValueObservation!
    
    func update(model: NotificationsItemProtocol) {
        isReadObservation = nil
        self.model = model
        self.senderView.image = model.image
        self.titleLabel.text = model.title
        self.subTitleLabel.text = model.subTitle
        isReadObservation = self.observe(\.model.isRead, options: [.initial, .new], changeHandler: { mySelf, change in
            let newValue = change.newValue!
            mySelf.isReadIndicator.isShowing = !newValue
        })
    }
    
    // MARK: UITableViewCell
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
