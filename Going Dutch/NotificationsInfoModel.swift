//
//  NotificationsInfoModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

class NotificationsInfoModel: NSObject {
    @objc dynamic var messageCount: Int = 0
    
    func determineMessageCount() {
        messageCount = 1
    }
    
    // MARK: NSObject
}
