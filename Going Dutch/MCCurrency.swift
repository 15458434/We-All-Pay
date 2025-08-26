//
//  MCCurrency.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData

@objc(MCCurrency) public final class MCCurrency: NSManagedObject {

    // MARK: NSManagedObject
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.setPrimitiveValue(UUID().uuidString, forKey: "uniqueID")
        let now = Date()
        self.setPrimitiveValue(now, forKey: "dateCreated")
        self.setPrimitiveValue(now, forKey: "dateModified")
    }
    
    // MARK: NSObject
}
