//
//  MCPathComponentsToOpenProtocol.swift
//  We all pay
//
//  Created by Mark Cornelisse on 19/11/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData

@objc protocol MCPathComponentsToOpenProtocol: NSObjectProtocol {
    @objc(prepareForUseWithPathComponentsToOpen:) func prepareForUse(with pathComponentsToOpen: [NSManagedObject])
}
