//
//  MCPaymentPresence.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPaymentPresence) public final class MCPaymentPresence: NSManagedObject {
    
    // MARK: NSManagedObject
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.setPrimitiveValue(UUID().uuidString, forKey: #keyPath(MCPaymentPresence.uniqueId))
        let now = Date()
        self.setPrimitiveValue(now, forKey: #keyPath(MCPaymentPresence.dateCreated))
        self.setPrimitiveValue(now, forKey: #keyPath(MCPaymentPresence.dateModified))
    }
    
    // MARK: NSObject
}
