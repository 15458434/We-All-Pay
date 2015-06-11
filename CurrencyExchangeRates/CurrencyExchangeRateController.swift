//
//  CurrencyExchangeRateController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/05/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc public class CurrencyExchangeRateController: NSObject {
    
    // MARK: New In this class
    public private(set) var exchangeRates: [Currency]!
    
    public class func getCurrencyDictionary() -> NSDictionary {
        let path = NSBundle.mainBundle().pathForResource("Currency info", ofType: "plist")
        let currencyDictionaryFromPlist = NSDictionary(contentsOfFile: path!)
        println(currencyDictionaryFromPlist)
        return currencyDictionaryFromPlist!
    }
    
    public func prepareExchangeRates() {
        // Read ExchangeRates.plist
        // Store in Array
        
    }
    
    public func getExchangeRate(fromCode: String, toCode: String, completion: ((result: ExchangeRate!, error: NSError!)->())) {
        // Are currency codes valid?
        // Are saved exchange rates still valid?
        // If invalid get latest and return values when retrieved.
        // If valid return values.
    }
    
    private func getLatestValues(completion: ((error: NSError!)->()) ) {
        
    }
    
    // MARK: Inherited from NSObject
}