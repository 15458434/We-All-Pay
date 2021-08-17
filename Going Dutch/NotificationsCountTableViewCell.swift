//
//  NotificationsCountTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit
import WeAllPayDesignableUI

@objc(MCNotificationsCountTableViewCell) final class NotificationsCountTableViewCell: UITableViewCell {
    @objc private weak var model: NotificationsInfoModel!
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var countView: UnreadNotificationsCountView!
    
    private var messageCountObservation: NSKeyValueObservation!
    
    func update(model: NotificationsInfoModel?) {
        if model != nil {
            self.model = model
            messageCountObservation = self.observe(\.model.messageCount, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let model = mySelf.model else {
                    return
                }
                
                let messageCount = model.messageCount
                if messageCount > 0 {
                    mySelf.countView.isHidden = false
                    mySelf.countView.count = messageCount
                } else {
                    mySelf.countView.isHidden = true
                }
            })
        } else {
            self.messageCountObservation = nil
            self.model = nil
        }
    }
    
    // MARK: UITableViewCell
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
