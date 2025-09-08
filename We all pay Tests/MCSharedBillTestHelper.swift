//
//  MCSharedBillTestHelper.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 04/08/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

@testable import We_all_pay

import CoreData

extension MCSharedBill {
    
    @objc(isPresentWithFirstName:andLastName:andEmailAddress:) func isPresent(firstName: String, lastName: String, emailAddress: String) -> Bool {
        let request = MCPerson.fetchRequest()
        let sortDescriptor1 = NSSortDescriptor(key: #keyPath(MCPerson.firstName), ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: #keyPath(MCPerson.lastName), ascending: true)
        request.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        let predicate = NSPredicate(format: "ANY sharedBill = %@ AND firstName = %@ AND lastName = %@ AND ANY emailAddress.emailAddress = %@", self, firstName, lastName, emailAddress)
        request.predicate = predicate
        
        guard let context = managedObjectContext else {
            print("Managed object context is nil")
            return false
        }
        
        do {
            let result = try context.fetch(request)
            return result.count > 0
        } catch {
            print("Error checking if person is present: \(error)")
            return false
        }
    }
    
}
