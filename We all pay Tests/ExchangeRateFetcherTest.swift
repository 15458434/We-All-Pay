//
//  ExchangeRateFetcherTest.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit
import XCTest

class ExchangeRateFetcherTest: XCTestCase {
    var fetcher: ExchangeRateFetcher!
    
    override func setUp() {
        super.setUp()
        
        fetcher = ExchangeRateFetcher()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsLastFetchOlderThanAnHour() {
        let emptyFetcher = ExchangeRateFetcher()
        XCTAssertFalse(emptyFetcher.isLastFetchOlderThanAnHour, "Should be false nothing is fetched.")
        let expectation = self.expectationWithDescription("isLastFetchOlderThanHour")
        emptyFetcher.fetchFromOpenExchangeRates("EUR", toCode: "RUB") { (fromCode, toCode, exchangeRate, error) -> () in
            XCTAssertTrue(emptyFetcher.isLastFetchOlderThanAnHour, "Should be true when fetched.")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(90, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout error: \(error)")
        })
    }

    func testFetchFromOpenExchangeRates() {
        let expectation = self.expectationWithDescription("fetchFromOpenExchangeRates")
        fetcher.fetchFromOpenExchangeRates("EUR", toCode: "USD") { (fromCode, toCode, exchangeRate, error) -> () in
            XCTAssertNil(error, "Error fetchingExchangeRate: \(error)")
            println(exchangeRate)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(90, handler: { (error) -> Void in
            XCTAssertNil(error, "Error waiting for exchangeRate results: \(error)")
        })
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
