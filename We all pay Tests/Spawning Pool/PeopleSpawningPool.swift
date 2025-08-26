//
//  PeopleSpawningPool.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 20/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

@testable import We_all_pay;

import UIKit

final class PeopleSpawningPool: NSObject {
    private let eventModel: EventModel
    
    init(eventModel: EventModel) {
        self.eventModel = eventModel
        super.init()
    }
    
    func createPerson(firstName: String? = nil, lastName: String? = nil, emailAddress: String? = nil) -> MCPerson {
        let person = eventModel.addPerson()
        person.firstName = firstName
        person.lastName = lastName
        if let emailAddress {
            let personModel = PersonModel(with: person)
            personModel.add(emailAddress: emailAddress)
        }
        return person
    }
    
    // MARK: NSObject
}
