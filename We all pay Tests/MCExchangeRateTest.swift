//
//  MCExchangeRateTest.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 02/09/2025.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//
@testable import We_all_pay

import XCTest
import CoreData

class MCExchangeRateTest: XCTestCase {
    
    private var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        WeAllPayStoreController.defaultStore.openStore(of: NSInMemoryStoreType)
        context = WeAllPayStoreController.defaultStore.viewContext
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInsert() {
        let newlyInsertedExchangeRate = MCExchangeRate(context: context)
        XCTAssertNotNil(newlyInsertedExchangeRate.uniqueID, "unique ID not present.")
        XCTAssertNotNil(newlyInsertedExchangeRate.dateCreated, "dateCreated not present.")
        XCTAssertNotNil(newlyInsertedExchangeRate.dateModified, "dateModified not present.")
        XCTAssert(newlyInsertedExchangeRate.status!.int16Value == MCExchangeRateStatus.valid.rawValue, "shortValue should be valid after creating")
    }
    
}
