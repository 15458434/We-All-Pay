//
//  ExchangeRateFetcher.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

class ExchangeRateFetcher: NSObject {
    let currencyController: CurrencyController = CurrencyController()
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
    
    func calculateExchangeRate(fromCode: String, toCode: String) -> Double {
        let fromToBaseRate = rates[fromCode]!
        let toToBaseRate = rates[toCode]!
        return toToBaseRate / fromToBaseRate
    }
    
    func exchangeRate(fromCode: String, toCode: String, completionHandler: (fromCode: String, toCode: String, exchangeRate: NSNumber!, error: NSError!) -> ()) {
        let thisOperationQueue = NSOperationQueue.currentQueue()!
        if isLastFetchOlderThanAnHour {
            fetchFromOpenExchangeRates({ (baseCurrency, rates, error) -> () in
                if error != nil {
                    completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: nil, error: error)
                    return
                }
                let exchangeRate = self.calculateExchangeRate(fromCode, toCode: toCode)
                thisOperationQueue.addOperationWithBlock({ () -> Void in
                    completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: exchangeRate, error: nil)
                })
            })
        } else {
            let rate = calculateExchangeRate(fromCode, toCode: toCode)
            completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: rate, error: nil)
        }
    }
    
    func fetchFromOpenExchangeRates(completionHandler: (baseCurrency: String!, rates: Dictionary<String, Double>!, error: NSError?) -> ()) {
        if isFetching {
            let error = NSError(domain: "ExchangeRateFetcher", code: 1, userInfo: ["reason": "Already fetching"])
            completionHandler(baseCurrency: nil, rates: nil, error: error)
            return
        }
        isFetching = true
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let url = NSURL(string: "https://openexchangerates.org/api/latest.json?app_id=cba02a60bd89412095c84ecb65b6326a");
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                print("Error fetching exchangeRate from OpenExchangeRates: \(error)")
                completionHandler(baseCurrency: nil, rates: nil, error: error)
                self.isFetching = false
                return
            }
            
            let httpResp = response as! NSHTTPURLResponse
            if (httpResp.statusCode == 200) {
                do {
                    let jsonResponseDictonary = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! Dictionary<String, AnyObject>
                    let baseCurrencyCode = jsonResponseDictonary["base"] as? String
                    let rates = jsonResponseDictonary["rates"] as? Dictionary<String, Double>
                    let date = NSDate(timeIntervalSince1970: Double((jsonResponseDictonary["timestamp"] as? Int)!))
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.baseCurrencyCode = baseCurrencyCode
                        self.rates = rates
                        self.date = date
                        completionHandler(baseCurrency: baseCurrencyCode, rates: rates, error: nil)
                            self.isFetching = false
                    })
                } catch let error {
                    // JSON Error
                    print("Error reading exchangeRatesFromJSON: \(error)")
                    let jsonError = NSError(domain: "We all pay", code: 0, userInfo: ["Reason": "Error parsing json"])
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        completionHandler(baseCurrency: nil, rates: nil, error: jsonError)
                        self.isFetching = false
                    })
                }
            } else {
                // Status code != 200
                let error = NSError(domain: "ExchangeRateFetcher", code: 2, userInfo: ["reason": "HTTP Response code: \(httpResp)", "response": httpResp])
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completionHandler(baseCurrency: nil, rates: nil, error: error)
                    self.isFetching = false
                })
            }
        }
        task.resume()
    }
    
    func isCurrencyCodeAvailableInRates(code: String) -> Bool {
        if let _ = rates[code] {
            return true
        } else {
            print("CurrencyCode: \(code) not present.")
            return false
        }
    }
    
    internal subscript(code: String) -> Double {
        return rates[code]!
    }
}