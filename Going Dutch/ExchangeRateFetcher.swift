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
    
    var isLastFetchOlderThanAnHour: Bool {
        if date == nil {
            return false
        }
        
        let now = NSDate()
        let intervalSinceLastFetch = now.timeIntervalSinceDate(self.date)
        if intervalSinceLastFetch <= 3600.0 {
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
    
    func fetchFromOpenExchangeRates(fromCode: CurrencyISOCode, toCode: CurrencyISOCode, completionHandler: (fromCode: CurrencyISOCode, toCode: CurrencyISOCode, exchangeRate: ExchangeRateValue!, error: NSError!) -> ()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let url = NSURL(string: "http://openexchangerates.org/api/latest.json?app_id=cba02a60bd89412095c84ecb65b6326a");
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let realError = error {
                println("Error fetching exchangeRate from OpenExchangeRates: \(realError)")
                completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: nil, error: realError)
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
                    })
                } else {
                    // JSON Error
                    println("Error reading exchangeRatesFromJSON: \(jsonError)")
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: nil, error: jsonError)
                    })
                }
            } else {
                // Status code != 200
                
            }
        }
        task.resume()
    }
}