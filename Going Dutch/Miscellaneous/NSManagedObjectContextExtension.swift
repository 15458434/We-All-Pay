//
//  NSManagedObjectContextExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 13/12/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    @objc(performWithBlock:) func perform(_ block: @escaping ((_ context: NSManagedObjectContext)->())) {
        self.perform { [unowned self] in
            block(self)
        }
    }
}
