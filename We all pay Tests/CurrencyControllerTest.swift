//
//  CurrencyControllerTest.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation
import XCTest

class CurrencyControllerTest: XCTestCase {
    var currencyController: CurrencyController!
    
    override func setUp() {
        super.setUp()
        
        currencyController = CurrencyController()
        XCTAssertNotNil(currencyController, "Currency controller should be present.")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCurrencies() {
        XCTAssertEqual(currencyController.currencies.count, 158, "Amount of currencies should be 158.")
    }
    
    func testSubscript() {
        let result = currencyController[5]
        let name = result["name"] as! String
        let code = result["code"] as! String
        XCTAssertNotNil(name, "Name should be presnt.")
        XCTAssertNotNil(code, "Code should be present.")
    }
}
