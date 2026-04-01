//
//  CurrencyController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 13/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation
import UIKit

@objc final public class CurrencyController: NSObject {
    public let currencies: [Currency]
    
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
            }).map { Currency(name: $0["name"] as! String, code: $0["code"] as! String) }
        } else {
            currencies = readCurrencies.map {
                Currency(name: $0["name"] as! String, code: $0["code"] as! String)
            }
        }

        super.init()
    }
    
    public func currency(code: String) -> Currency? {
        currencies.first(where: { $0.code == code })
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
