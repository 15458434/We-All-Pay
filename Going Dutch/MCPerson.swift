//
//  MCPerson.swift
//  
//
//  Created by Mark Cornelisse on 26/08/2025.
//

import UIKit

@objc(MCPerson) public final class MCPerson: NSManagedObject {

    // MARK: NSManagedObject
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.setPrimitiveValue(UUID().uuidString, forKey: #keyPath(MCPerson.uniquePersonId))
        let now = Date()
        self.setPrimitiveValue(now, forKey: #keyPath(MCPerson.dateCreated))
        self.setPrimitiveValue(now, forKey: #keyPath(MCPerson.dateModified))
    }
    
    // MARK: NSObject
}
