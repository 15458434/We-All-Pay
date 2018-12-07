//
//  CoreDataSaveHandlerWhenEnteringBackground.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/08/2018.
//  Copyright © 2018 Mark Cornelisse. All rights reserved.
//

import UIKit
import CoreData

@objc(MCCoreDataSaveHandlerWhenEnteringBackground) class CoreDataSaveHandlerWhenEnteringBackground: NSObject {
    @objc let context: NSManagedObjectContext
    private(set) var willSaveObserver: NSObjectProtocol!
    private(set) var didSaveObserver: NSObjectProtocol!
    @objc private(set) var isSaving: Bool = false
    
    @objc(initWithContext:) init(with context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    @objc(saveAndEndBackgroundTaskWithIdentifier:) func saveAndEndBackgroundTask(with identifier: UIBackgroundTaskIdentifier) {
        guard context.hasChanges else {
            debugPrint("There are no changes to save.")
            UIApplication.shared.endBackgroundTask(identifier)
            return
        }
        let notificationCenter = NotificationCenter.default
        self.willSaveObserver = notificationCenter.addObserver(forName: Notification.Name.NSManagedObjectContextWillSave, object: context, queue: nil, using: { [unowned self] (notification) in
            debugPrint("will save observed")
            self.isSaving = true
        })
        self.didSaveObserver = notificationCenter.addObserver(forName: Notification.Name.NSManagedObjectContextDidSave, object: context, queue: nil, using: { [unowned self] (notification) in
            debugPrint("did save observed")
            self.isSaving = false
            UIApplication.shared.endBackgroundTask(identifier)
        })
        try! context.save()
    }
    
    
    // MARK: NSObject
}
