//
//  MCExchangeRate.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCExchangeRate) public final class MCExchangeRate: NSManagedObject {
    
    // MARK: NSManagedObject
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.setPrimitiveValue(UUID().uuidString, forKey: #keyPath(MCExchangeRate.uniqueID))
        let now = Date()
        self.setPrimitiveValue(now, forKey: #keyPath(MCEmailAddress.dateCreated))
        self.setPrimitiveValue(now, forKey: #keyPath(MCEmailAddress.dateModified))
    }
    
    // MARK: NSObject

}
