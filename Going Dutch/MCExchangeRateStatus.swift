//
//  MCExchangeRateStatus.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc enum MCExchangeRateStatus: Int16 {
    case valid
    case invalid
    case fetching
    
    init?(number: NSNumber) {
        let rawValue = Int16(exactly: number.intValue)
        self.init(rawValue: rawValue ?? Int16(NSNotFound))
    }
    
    var number: NSNumber {
        NSNumber(value: self.rawValue)
    }
}
