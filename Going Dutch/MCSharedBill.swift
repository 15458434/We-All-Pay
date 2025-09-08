//
//  MCSharedBill.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData

import CurrencyConverter

@objc(MCSharedBill) public final class MCSharedBill: NSManagedObject {
    
    // MARK: NSManagedObject
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.setPrimitiveValue(UUID().uuidString, forKey: "uniqueBillId")
        self.setPrimitiveValue(NSNumber(value: false), forKey: "hasTheMailBeenSent")
        let now = Date()
        self.setPrimitiveValue(now, forKey: "dateCreated")
        self.setPrimitiveValue(now, forKey: "dateModified")
        let currencyController = CurrencyController()
        let currencyModel = CurrencyModel(managedObjectContext: self.managedObjectContext!, currencyController: currencyController)
        let mainCurrency = try! currencyModel.generateCurrencyFromSelectedLocale()
        self.setPrimitiveValue(mainCurrency, forKey: "mainCurrency")
    }
    
    // MARK: NSObject
    
}
