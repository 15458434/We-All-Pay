//
//  NSDecimalNumberExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 12/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import Foundation

extension NSDecimalNumber {
    static var zero: NSDecimalNumber {
        NSDecimalNumber(decimal: Decimal.zero)
    }
}
