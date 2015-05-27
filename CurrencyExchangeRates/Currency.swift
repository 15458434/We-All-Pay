//
//  Currency.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/05/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc public class Currency: NSObject, Printable {
    public var name: String!
    public var code: String!
    public var symbol: String!
    
    // MARK: New in this class
    
    init(name: String, code: String, symbol: String) {
        self.name = name
        self.code = code
        self.symbol = symbol
        super.init()
    }
    
    // MARK: Printable
    
    public override var description: String {
        return "Currency: Name:\(self.name), Code:\(self.code) and Symbol:\(self.symbol)"
    }
    
    // MARK: Inherited by NSObject
    
}