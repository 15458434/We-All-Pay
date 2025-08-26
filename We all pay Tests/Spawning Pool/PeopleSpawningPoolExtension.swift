//
//  PeopleSpawningPoolExtension.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 21/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

@testable import We_all_pay;

import Foundation

extension PeopleSpawningPool {
    @objc func spawnMark() -> MCPerson {
        let mark = createPerson(
            firstName: "Mark",
            lastName: "Cornelisse",
            emailAddress: "m.p.cornelisse@gmail.com"
        )
        return mark
    }
    
    @objc func spawnYvette() -> MCPerson {
        let yvette = createPerson(
            firstName: "Yvette"
        )
        return yvette
    }
    
    @objc func spawnMerit() -> MCPerson {
        let merit = createPerson(
            firstName: "Merit",
            lastName: "Koelink"
        )
        return merit
    }
}
