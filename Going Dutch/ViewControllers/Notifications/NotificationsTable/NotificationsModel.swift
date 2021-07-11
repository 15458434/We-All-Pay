//
//  NotificationsModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

class NotificationsModel: NSObject {
    @objc dynamic private(set) var notifications: [NotificationsItemProtocol] = [NotificationsItemProtocol]()
    
    /// addItem to the notifications array in the correct order and trigger KVO.
    /// - Parameter notificationsItem: The item add to the notifications array.
    private func addItem(_ notificationsItem: NotificationsItemProtocol) {
        let mutableNotifications: NSMutableArray = self.mutableArrayValue(forKey: "notifications")
        let index = mutableNotifications.indexOfObject { item, index, stop in
            let item = item as! NotificationsItemProtocol
            if notificationsItem.date <= item.date {
                return false
            } else {
                stop.pointee = ObjCBool(true)
                return true
            }
        }
        if index == NSNotFound {
            mutableNotifications.insert(notificationsItem, at: mutableNotifications.count)
        } else {
            mutableNotifications.insert(notificationsItem, at: index)
        }
    }
    
    
    // MARK: NSObject
    
    override init() {
        super.init()
        // TODO: Remove this population code to test the TableView.
        let item1 = NotificationsItem(uuid: UUID(), date: Date(), image: #imageLiteral(resourceName: "We All Pay - Sender"), title: "Your feedback please.", subTitle: "We can improve this.")
        let item2 = NotificationsItem(uuid: UUID(), date: Date(), image: #imageLiteral(resourceName: "We All Pay - Sender"), title: "Your feedback please 2.", subTitle: "We can improve this 2.")
        let item3 = NotificationsItem(uuid: UUID(), date: Date(), image: #imageLiteral(resourceName: "We All Pay - Sender"), title: "Your feedback please 3.", subTitle: "We can improve this 3.")
        let item4 = NotificationsItem(uuid: UUID(), date: Date(), image: #imageLiteral(resourceName: "We All Pay - Sender"), title: "Your feedback please 4.", subTitle: "We can improve this 4.")
        self.addItem(item4)
        self.addItem(item2)
        self.addItem(item1)
        self.addItem(item3)
    }
}

@objc protocol NotificationsItemProtocol {
    var uuid: UUID { get }
    var date: Date { get }
    var image: UIImage? { get set }
    var title: String! { get set }
    var subTitle: String? { get set }
}

class NotificationsItem: NSObject, NotificationsItemProtocol {
    
    init(uuid: UUID, date: Date? = nil) {
        self.uuid = uuid
        if let date = date {
            self.date = date
        } else {
            self.date = Date()
        }
        super.init()
    }
    
    convenience init(uuid: UUID, date: Date? = nil, image: UIImage? = nil, title: String!, subTitle: String? = nil) {
        self.init(uuid: uuid)
        self.image = image
        self.title = title
        self.subTitle = subTitle
    }
    
    // MARK: NotificationsItemProtocol
    
    let uuid: UUID
    var date: Date
    var image: UIImage?
    var title: String!
    var subTitle: String?
    
    // MARK: NSObject
}
