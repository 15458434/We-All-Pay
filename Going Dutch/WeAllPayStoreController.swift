//
//  WeAllPayStoreController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData
import os
import CurrencyConverter

fileprivate let WeAllPayStoreFileName = "persistentStore"
fileprivate let WeAllPayStoreDirectoryName = "WeAllPayStore/StoreContent"
fileprivate let WeAllPayStoreModelName = "WeAllPayStore"

final class WeAllPayStoreController: NSObject {
    let logger = Logger(category: "WeAllPayStoreController")
    @objc dynamic private(set) var error: NSError!
    
    private var container: NSPersistentContainer!
    
    private var _fetcher: ExchangeRateFetcher!
    @objc var fetcher: ExchangeRateFetcher {
        if _fetcher == nil {
            _fetcher = ExchangeRateFetcher()
        }
        return _fetcher
    }
    
    @objc static let defaultStore = WeAllPayStoreController()
    
    private var applicationDocumentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    
    private var weAllPayStoreURL: URL {
        let weAllPayStorageFolder = self.applicationDocumentsDirectory.appendingPathComponent(WeAllPayStoreDirectoryName)
        do {
            try FileManager.default.createDirectory(at: weAllPayStorageFolder, withIntermediateDirectories: true, attributes: nil)
        } catch {
            DispatchQueue.main.async {
                self.error = error as NSError
            }
        }
        let result = weAllPayStorageFolder.appendingPathComponent(WeAllPayStoreFileName)
        debugPrint("WeAllPayStorageFile: \(result)")
        return result
    }
    
    #if SCREENSHOTS
    func openStore(completionHandler: ((_ store: WeAllPayStoreController, _ success: Bool) -> ())?) {
        if self.container == nil {
            container = NSPersistentContainer(name: WeAllPayStoreModelName)
            let weAllPayStoreURL = URL(string: "/dev/null")!
            let storeDescription = NSPersistentStoreDescription(url: weAllPayStoreURL)
            storeDescription.type = NSInMemoryStoreType
            storeDescription.setOption(NSNumber(value: true), forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            container.persistentStoreDescriptions = [storeDescription]
            container.loadPersistentStores { storeDescription, error in
                guard error == nil else {
                    debugPrint("Unresolved error: \(String(describing: error))")
                    DispatchQueue.main.async {
                        self.error = error! as NSError
                    }
                    completionHandler?(self, false)
                    fatalError("This shouldn't happen.")
                }
                completionHandler(self, true)
            }
            self.viewContext.automaticallyMergesChangesFromParent = true;
            self.viewContext.undoManager = UndoManager()
        }
    }
    #else
    @objc func openStore() {
        openStore(of: NSSQLiteStoreType)
    }
    
    @objc(openStoreOfType:) func openStore(of type: String) {
        if container != nil {
            return
        }
        guard type == NSSQLiteStoreType || type == NSInMemoryStoreType else {
            fatalError("Only NSSQLiteStoreType or NSInMemoryStoreType are supported")
        }
        container = NSPersistentContainer(name: WeAllPayStoreModelName)
        let weAllPayStoreURL: URL
        if type == NSInMemoryStoreType {
            weAllPayStoreURL = URL(string: "/dev/null")!
        } else {
            weAllPayStoreURL = self.weAllPayStoreURL
        }
        let storeDescription = NSPersistentStoreDescription(url: weAllPayStoreURL)
        storeDescription.type = type
        storeDescription.setOption(NSNumber(value: true), forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        storeDescription.setOption(NSNumber(value: true), forKey: NSInferMappingModelAutomaticallyOption)
        storeDescription.setOption(NSNumber(value: true), forKey: NSMigratePersistentStoresAutomaticallyOption)
        // NSPersistentHistoryTrackingKey is needed to Core Data to be able to store on iPadOS. Test on iPad Pro 13-inch (M4) (17.5) Simulator.
        storeDescription.setOption(NSNumber(value: true), forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                debugPrint("Unresolved error: \(String(describing: error))")
                DispatchQueue.main.async {
                    self.error = error! as NSError
                }
                fatalError("This shouldn't happen.")
            }
        }
        self.viewContext.retainsRegisteredObjects = true
        self.viewContext.undoManager = UndoManager()
        self.viewContext.undoManager!.disableUndoRegistration()
        self.viewContext.automaticallyMergesChangesFromParent = true
    }
    #endif
    
    @objc var viewContext: NSManagedObjectContext {
        self.container.viewContext
    }
    
    func performBackgroundTask(_ block: @escaping ((_ backgroundContext: NSManagedObjectContext) -> Void)) {
        container.performBackgroundTask(block)
    }
    
    @objc func saveViewContext() {
        logger.trace(#function)
        logger.info("viewContext.hasChanges: \(self.viewContext.hasChanges)")
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
                logger.info("viewContext: Successfully saved.")
            } catch {
                let nsError = error as NSError
                logger.error("viewContext: Failed saving:\nError Domain: \(nsError.domain)\nError Code: \(nsError.code)\nDescription: \(nsError.localizedDescription)\nUser Info: \(nsError.userInfo)")
            }
        }
    }
    
    @objc func beginUndoGroup() {
        viewContext.undoManager!.enableUndoRegistration()
        viewContext.undoManager!.beginUndoGrouping()
    }
    
    @objc func beginUndoGroupWithoutRegistration() {
        viewContext.undoManager!.beginUndoGrouping()
    }
    
    @objc func endUndoGroup() {
        viewContext.undoManager!.endUndoGrouping()
        viewContext.undoManager!.disableUndoRegistration()
    }
    
    @objc func endUndoGroupWithoutRegistration() {
        viewContext.undoManager!.endUndoGrouping()
    }
    
    @objc func endUndoGroupAndProcess() {
        viewContext.undoManager!.endUndoGrouping()
        viewContext.undoManager!.disableUndoRegistration()
        viewContext.processPendingChanges()
    }
    
    @objc func endUndoGroupAndProcessWithoutRegistration() {
        viewContext.undoManager!.endUndoGrouping()
        viewContext.processPendingChanges()
    }
    
    @objc func endUndoGroupAndUndo() {
        viewContext.undoManager!.endUndoGrouping()
        viewContext.undoManager!.undoNestedGroup()
        viewContext.undoManager!.disableUndoRegistration()
    }
    
    @objc func endUndoGroupAndUndoWithoutRegistration() {
        viewContext.undoManager!.endUndoGrouping()
        viewContext.undoManager!.undoNestedGroup()
    }
    
    @objc func resetError() {
        self.error = nil
    }
    
    // MARK: NSObject
}
