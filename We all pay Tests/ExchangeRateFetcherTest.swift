//
//  ExchangeRateFetcherTest.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit
import XCTest

extension ExchangeRateFetcher {
    var allCurrenciesAvailable: Bool {
        for currency in currencyController.currencies {
            if !isCurrencyCodeAvailableInRates(currency["code"]) {
                return false
            }
        }
        return true
    }
}

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
        XCTAssertTrue(emptyFetcher.isLastFetchOlderThanAnHour, "Should be true nothing is fetched.")
        let expectation = self.expectation(description: "isLastFetchOlderThanHour")
        emptyFetcher.fetchFromOpenExchangeRates{ (baseCurrency, rates, error) -> () in
            XCTAssertFalse(emptyFetcher.isLastFetchOlderThanAnHour, "Should be true when fetched.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 90, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout error: \(String(describing: error))")
        })
    }

    func testFetchFromOpenExchangeRates() {
        let expectation = self.expectation(description: "fetchFromOpenExchangeRates")
        fetcher.fetchFromOpenExchangeRates { (baseCurrency, rates, error) -> () in
            XCTAssertNil(error, "Error fetchingExchangeRate: \(String(describing: error))")
            XCTAssertNotNil(baseCurrency, "baseCurrency can't be nil")
            XCTAssertNotNil(rates, "Rates can't be nil.")
            XCTAssertNotNil(self.fetcher.baseCurrencyCode, "BaseCurrency can't be nil")
            XCTAssertNotNil(self.fetcher.rates, "Rates can't be nil")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 90, handler: { (error) -> Void in
            XCTAssertNil(error, "Error waiting for exchangeRate results: \(String(describing: error))")
            XCTAssertTrue(self.fetcher.allCurrenciesAvailable, "All currencies should be available.")
        })
    }
    
    func testExchangeRate() {
        let expectation = self.expectation(description: "exchangeRate")
        let repeatFetcher = ExchangeRateFetcher()
        repeatFetcher.exchangeRate("EUR", toCode: "BTC") { (fromCode, toCode, exchangeRate, error) -> () in
            XCTAssertNil(error, "Error fetching ExchangeRate")
            XCTAssertNotNil(exchangeRate, "ExchangeRate can't be nil")
            XCTAssertNotNil(repeatFetcher.baseCurrencyCode, "BaseCurrency can't be nil")
            XCTAssertNotNil(repeatFetcher.rates, "Rates can't be nil")
            repeatFetcher.exchangeRate("BTC", toCode: "RUB", completionHandler: { (fromCode, toCode, exchangeRate, error) -> () in
                XCTAssertNil(error, "Error fetching exchangeRate")
                XCTAssertNotNil(exchangeRate, "ExchangeRate can't be nil")
                expectation.fulfill()
            })
        }
        waitForExpectations(timeout: 90, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout error: \(String(describing: error))")
        })
    }
    
    func testCodeSubscript() {
        let expectation = self.expectation(description: "codeSubscript")
        let codeSubscriptFetcher = ExchangeRateFetcher()
        codeSubscriptFetcher.fetchFromOpenExchangeRates { (baseCurrency, rates, error) -> () in
            Thread.sleep(forTimeInterval: 1.0)
            XCTAssertNil(error, "Error fetching exchangeRates")
            XCTAssertNotNil(codeSubscriptFetcher["EUR"], "ExchangeRate should be valid")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 90, handler: { (error) -> Void in
            XCTAssertNil(error, "Timeout error: \(String(describing: error))")
        })
    }
}
