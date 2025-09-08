//
//  MCPayment.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPayment) public final class MCPayment: NSManagedObject {

    // MARK: NSManagedObject
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.setPrimitiveValue(UUID().uuidString, forKey: #keyPath(MCPayment.uniquePaymentId))
        let now = Date()
        self.setPrimitiveValue(now, forKey: #keyPath(MCPayment.dateCreated))
        self.setPrimitiveValue(now, forKey: #keyPath(MCPayment.dateModified))
    }
    
    // MARK: NSObject
}
