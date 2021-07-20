//
//  NotificationsModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

final class NotificationsModel: NSObject {
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
    
    private func remove(at index: Int) {
        let mutableNotifications: NSMutableArray = self.mutableArrayValue(forKey: "notifications")
        mutableNotifications.removeObject(at: index)
    }
    
    func add() {
        let item = NotificationsItem(uuid: UUID(), date: Date(), image: #imageLiteral(resourceName: "We All Pay - Sender"), title: UUID().uuidString, subTitle: "\(notifications.count)", isRead: false)
        self.addItem(item)
    }
    
    func updateIsRead(for index: Int) {
        let item = notifications[index]
        item.isRead = true
    }
    
    // MARK: NSObject
    
}

@objc protocol NotificationsItemProtocol {
    var uuid: UUID { get }
    var date: Date { get }
    var image: UIImage? { get set }
    var title: String! { get set }
    var subTitle: String? { get set }
    var isRead: Bool { get set }
}

class NotificationsItem: NSObject, NotificationsItemProtocol {
    
    init(uuid: UUID, date: Date? = nil, isRead: Bool) {
        self.uuid = uuid
        if let date = date {
            self.date = date
        } else {
            self.date = Date()
        }
        self.isRead = isRead
        super.init()
    }
    
    convenience init(uuid: UUID, date: Date? = nil, image: UIImage? = nil, title: String!, subTitle: String? = nil, isRead: Bool) {
        self.init(uuid: uuid, isRead: isRead)
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
    @objc dynamic var isRead: Bool
    
    // MARK: NSObject
}
