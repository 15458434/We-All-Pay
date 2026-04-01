//
//  LoggerExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 21/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation
import os

extension Logger {
    init(category: String) {
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        self.init(subsystem: bundleIdentifier, category: category)
    }
}
