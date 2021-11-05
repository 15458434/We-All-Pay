//
//  CurrencyController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 13/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation
import UIKit

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

@objc final public class CurrencyController: NSObject {
    @objc public let currencies: [Currency]
    
    @objc public func currencySymbol(_ code: String) -> String {
        return Locale.current.localizedString(forCurrencyCode: code) ?? ""
    }
    
    @objc init(with filterUnusedCurrencies: Bool) {
        let currencyFilePath = Bundle(identifier: "com.GreenHair.CurrencyConverter")!.path(forResource: "Available Currencies", ofType: "plist")
        let readCurrencies = NSArray(contentsOfFile: currencyFilePath!) as! [Dictionary<String, Any>]
        if filterUnusedCurrencies {
            currencies = readCurrencies.filter({ currencyDictionary in
                if let type = currencyDictionary["type"] as? Int {
                    return Currency.Kind(rawValue: type) == .payment
                } else {
                    return true
                }
            }).map {
                return Currency(name: $0["name"] as! String, code: $0["code"] as! String)
            }
        } else {
            currencies = readCurrencies.map {
                let name = $0["name"] as! String
                let code = $0["code"] as! String
                return Currency(name: name, code: code)
            }
        }

        super.init()
    }
    
    // MARK: NSObject
    
    @objc convenience public override init() {
        self.init(with: true)
    }
    
    public subscript(index: Int) -> Currency {
        return currencies[index]
    }
    
    @objc public subscript(code: String) -> String {
        let filteredDictionary = currencies.filter { $0.code == code }
        return filteredDictionary.first!.name
    }
}
