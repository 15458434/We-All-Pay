//
//  ExchangeRateFetcher.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

public typealias CurrencyISOCode = String
public typealias ExchangeRateValue = Double

class ExchangeRateFetcher: NSObject {
    internal let currencyController = CurrencyController()
    internal private(set) var baseCurrencyCode: String!
    internal private(set) var rates: Dictionary<String, Double>!
    internal private(set) var date: NSDate!
    
    internal private(set) var isFetching: Bool = false
    
    var isLastFetchOlderThanAnHour: Bool {
        if date == nil {
            return true
        }
        
        let now = NSDate()
        let intervalSinceLastFetch = now.timeIntervalSinceDate(self.date)
        if intervalSinceLastFetch >= 3600.0 {
            return true
        } else {
            return false
        }
    }
    
    func calculateExchangeRate(fromCode: CurrencyISOCode, toCode: CurrencyISOCode) -> ExchangeRateValue {
        let fromToBaseRate = rates[fromCode]!
        let toToBaseRate = rates[toCode]!
        return toToBaseRate / fromToBaseRate
    }
    
    func exchangeRate(fromCode: CurrencyISOCode, toCode: CurrencyISOCode, completionHandler: (fromCode: CurrencyISOCode, toCode: CurrencyISOCode, exchangeRate: ExchangeRateValue!, error: NSError!) -> ()) {
        if isLastFetchOlderThanAnHour {
            fetchFromOpenExchangeRates(fromCode, toCode: toCode, completionHandler: completionHandler)
        } else {
            let rate = calculateExchangeRate(fromCode, toCode: toCode)
            completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: rate, error: nil)
        }
    }
    
    func fetchFromOpenExchangeRates(fromCode: CurrencyISOCode, toCode: CurrencyISOCode, completionHandler: (fromCode: CurrencyISOCode, toCode: CurrencyISOCode, exchangeRate: ExchangeRateValue!, error: NSError!) -> ()) {
        if isFetching {
            let error = NSError(domain: "ExchangeRateFetcher", code: 1, userInfo: ["reason": "Already fetching"])
            completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: nil, error: error)
            return
        }
        isFetching = true
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let url = NSURL(string: "http://openexchangerates.org/api/latest.json?app_id=cba02a60bd89412095c84ecb65b6326a");
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let realError = error {
                println("Error fetching exchangeRate from OpenExchangeRates: \(realError)")
                completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: nil, error: realError)
                self.isFetching = false
                return
            }
            
            let httpResp = response as! NSHTTPURLResponse
            if (httpResp.statusCode == 200) {
                var jsonError: NSError?
                if let openExchangeRateDictonary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as? Dictionary<NSObject, AnyObject> {
                    let baseCurrencyCode = openExchangeRateDictonary["base"] as! String
                    let rates = openExchangeRateDictonary["rates"] as! Dictionary<String, Double>
                    let date = NSDate(timeIntervalSince1970: Double(openExchangeRateDictonary["timestamp"] as! Int))
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.baseCurrencyCode = baseCurrencyCode
                        self.rates = rates
                        self.date = date
                        let calculatedExchangeRate = self.calculateExchangeRate(fromCode, toCode: toCode)
                        completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: calculatedExchangeRate, error: nil)
                        self.isFetching = false
                    })
                } else {
                    // JSON Error
                    println("Error reading exchangeRatesFromJSON: \(jsonError)")
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: nil, error: jsonError)
                        self.isFetching = false
                    })
                }
            } else {
                // Status code != 200
                let error = NSError(domain: "ExchangeRateFetcher", code: 2, userInfo: ["reason": "HTTP Response code: \(httpResp)", "response": httpResp])
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: nil, error: error)
                    self.isFetching = false
                })
            }
        }
        task.resume()
    }
    
    func isCurrencyCodeAvailableInRates(code: CurrencyISOCode) -> Bool {
        if let exchangeRate = rates[code] {
            return true
        } else {
            println("CurrencyCode: \(code) not present.")
            return false
        }
    }
}