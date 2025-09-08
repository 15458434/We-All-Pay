//
//  MCCurrencyTest.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@testable import We_all_pay
@testable import CurrencyConverter

import XCTest
import CoreData  // Assuming Core Data is used for NSManagedObjectContext

// Import other necessary modules if required, e.g., @testable import CurrencyConverter
// @testable import We_all_pay  // If needed for internal access

class MCCurrencyTest: XCTestCase {
    
    private var context: NSManagedObjectContext!
    private var currencyModel: CurrencyModel!
    
    override func setUp() {
        super.setUp()
        WeAllPayStoreController.defaultStore.openStore(of: NSInMemoryStoreType)
        context = WeAllPayStoreController.defaultStore.viewContext
        currencyModel = CurrencyModel(managedObjectContext: context, currencyController: CurrencyController())
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGenerateCurrencyFromSelectedLocaleForContext() throws {
        let selectedCurrency = try currencyModel.generateCurrencyFromSelectedLocale()
        let currencyCode = Locale.current.currencyCode!
        XCTAssertEqual(selectedCurrency.code, currencyCode, "Wrong currency selected.")
        XCTAssertNotNil(selectedCurrency.uniqueID, "unique ID missing.")
        XCTAssertNotNil(selectedCurrency.dateCreated, "dateCreated is missing.")
        XCTAssertNotNil(selectedCurrency.dateModified, "dateModified is missing.")
    }
    
    func testGetCurrencyWithCode() {
        let selectedCurrency = currencyModel.currency(from: "USD")
        XCTAssertEqual(selectedCurrency.code, "USD", "Wrong currency selected.")
    }
    
}
