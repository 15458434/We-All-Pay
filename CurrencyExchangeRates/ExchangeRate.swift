//
//  ExchangeRate.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/05/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc public class ExchangeRate: NSObject, Printable {
    // MARK: New in this class
    public let fromCurrency: Currency
    public let toCurrency: Currency
    public let exchangeRate: Double
    
    init(from: Currency, to: Currency, exchangeRate: Double) {
        self.fromCurrency = from
        self.toCurrency = to
        self.exchangeRate = exchangeRate
        super.init()
    }
    
    // MARK: Printable
    
    public override var description: String {
        return "from:\(self.fromCurrency), to:\(self.toCurrency) with rate:\(self.exchangeRate)"
    }
    
    // MARK: Inherited from NSObject
}