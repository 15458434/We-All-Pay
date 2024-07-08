//
//  WeAllPayStoreController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData
import CurrencyConverter

fileprivate let WeAllPayStoreFileName = "persistentStore"
fileprivate let WeAllPayStoreDirectoryName = "WeAllPayStore/StoreContent"
fileprivate let WeAllPayStoreModelName = "WeAllPayStore"

@objc(MCWeAllPayStoreController) final class WeAllPayStoreController: NSObject {
    
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
            let weAllPayStoreURL = URL(string: "/dev/null")
            let storeDescription = NSPersistentStoreDescription(url: weAllPayStoreURL)
            storeDescription.type = NSInMemoryStoreType
            storeDescription.setOption(NSNumber(value: true), forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
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
        if container == nil {
            container = NSPersistentContainer(name: WeAllPayStoreModelName)
            let storeDescription = NSPersistentStoreDescription(url: weAllPayStoreURL)
            storeDescription.setOption(NSNumber(value: true), forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            storeDescription.setOption(NSNumber(value: true), forKey: NSInferMappingModelAutomaticallyOption)
            storeDescription.setOption(NSNumber(value: true), forKey: NSMigratePersistentStoresAutomaticallyOption)
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
    }
    #endif
    
    @objc var viewContext: NSManagedObjectContext {
        self.container.viewContext
    }
    
    func performBackgroundTask(_ block: @escaping ((_ backgroundContext: NSManagedObjectContext) -> Void)) {
        container.performBackgroundTask(block)
    }
    
    @objc func saveViewContext() {
        debugPrint("Saving viewContext: \(self.viewContext)")
        if self.viewContext.hasChanges {
            do {
                try self.viewContext.save()
                debugPrint("viewContext: Successfully saved.")
            } catch {
                debugPrint("viewContext: Failed saving: \(error)")
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
