//
//  PersistentContainer.swift
//  We all pay
//
//  Created by Mark Cornelisse on 01/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCWeAllPayPersistentContainer) public final class PersistentContainer: NSPersistentContainer {
    @objc(initWithName:andBundle:andInMemory:) public init(name: String, bundle: Bundle = .main, inMemory: Bool = false) {
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: [bundle]) else {
            fatalError("Failed to create NSManagedObjectModel")
        }
        super.init(name: name, managedObjectModel: managedObjectModel)
        configureDefaults(inMemory)
    }
    
    private func configureDefaults(_ inMemory: Bool = false) {
        if let storeDescription = persistentStoreDescriptions.first {
            storeDescription.shouldAddStoreAsynchronously = true
            if inMemory {
                storeDescription.url = URL(fileURLWithPath: "/dev/null")
                storeDescription.shouldAddStoreAsynchronously = false
            }
        }
    }
}
