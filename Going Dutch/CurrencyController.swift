//
//  CurrencyController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 13/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

public class Currency: NSObject {
    public let name: String
    public let code: String
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

public class CurrencyController: NSObject {
    public let currencies: [Currency]
    
    public func currencySymbol(_ code: String) -> String {
        return Locale.current.localizedString(forCurrencyCode: code) ?? ""
    }
    
    // MARK: NSObject
    
    public override init() {
        let currencyFilePath = Bundle(identifier: "com.GreenHair.CurrencyConverter")!.path(forResource: "Available Currencies", ofType: "plist")
        let readCurrencies = NSArray(contentsOfFile: currencyFilePath!) as! [Dictionary<String, String>]
        currencies = readCurrencies.map {
            return Currency(name: $0["name"]!, code: $0["code"]!)
        }
        super.init()
    }
    
    public subscript(index: Int) -> Currency {
        return currencies[index]
    }
    
    public subscript(code: String) -> String {
        let filteredDictionary = currencies.filter { $0.code == code }
        return filteredDictionary.first!.name
    }
}
