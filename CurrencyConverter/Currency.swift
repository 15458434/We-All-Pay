//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Mark Cornelisse on 29/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation

final public class Currency: NSObject {
    @objc(MCCurrencyType) enum Kind: Int {
        case unknown = 0
        case payment = 1
        case noOfficialcode = 2
        case unused = 3
        case legacy = 4
        case commodity = 5
    }
    @objc public let name: String
    @objc public let code: String
    public var symbol: String {
        return (Locale.current as NSLocale).displayName(forKey: .currencySymbol, value: code) ?? ""
    }
    
    // MARK: NSObject
    
    public init(name: String, code: String) {
        self.name = name
        self.code = code
        super.init()
    }
    
    subscript(key: String) -> String {
        switch (key) {
        case "name":
            return self.name
        case "code":
            return self.code
        case "symbol":
            return self.symbol
        default:
            return ""
        }
    }
}
