//
//  MCPersonExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 15/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData

extension MCPerson  {
    @objc var name: String {
        if let firstName {
            return firstName
        } else if let lastName {
            return lastName
        } else if let defaultEmailAddress = self.defaultEmailAddress() {
            return defaultEmailAddress
        } else {
            return "..."
        }
    }

    @objc var fullName: String {
        switch (firstName, lastName, defaultEmailAddress()) {
        case let (f, l, _) where f != nil && l != nil:
            return "\(f!) \(l!)"
        case let (f, l, _) where f != nil && l == nil:
            return f!
        case let (f, l, _) where f == nil && l != nil:
            return l!
        case let (f, l, d) where f == nil && l == nil && d != nil:
            return d!
        default:
            return "...";
        }
    }
}
