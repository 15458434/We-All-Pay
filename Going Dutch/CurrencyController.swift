//
//  CurrencyController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 13/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

public class CurrencyController: NSObject {
    public let currencies: [Dictionary<NSObject, AnyObject>]
    
    public override init() {
        let currencyFilePath = NSBundle.mainBundle().pathForResource("Available Currencies", ofType: "plist")
        currencies = NSArray(contentsOfFile: currencyFilePath!) as! [Dictionary<NSObject, AnyObject>]
        super.init()
    }
    
    public subscript(index: Int) -> Dictionary<NSObject, AnyObject> {
        return currencies[index]
    }
}
