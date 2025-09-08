//
//  MCPerson+TestHelper.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 16/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

@testable import We_all_pay

import CoreData

extension MCPerson {
    static func isTableInDatabaseEmpty(for managedObjectContext: NSManagedObjectContext) -> Bool {
        let request = MCPerson.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(firstName), ascending: true)]
        request.predicate = NSPredicate(value: true)
        let amountOfPeople = try! managedObjectContext.count(for: request)
        return amountOfPeople == 0
    }
}
