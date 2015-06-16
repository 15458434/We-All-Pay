//
//  CurrencyController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 13/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

public class CurrencyController: NSObject {
    public let currencies: [Dictionary<String, String>]
    
    public override init() {
        let currencyFilePath = NSBundle.mainBundle().pathForResource("Available Currencies", ofType: "plist")
        currencies = NSArray(contentsOfFile: currencyFilePath!) as! [Dictionary<String, String>]
        super.init()
    }
    
    public subscript(index: Int) -> Dictionary<String, String> {
        return currencies[index]
    }
    
    public subscript(code: String) -> String {
        let filteredDictionary = currencies.filter { $0["code"] == code }
        return filteredDictionary.first!["name"]!
    }
}
