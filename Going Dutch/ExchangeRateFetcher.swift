//
//  ExchangeRateFetcher.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

public class ExchangeRateFetcher: NSObject {
    public let currencyController: CurrencyController = CurrencyController()
    public private(set) var baseCurrencyCode: String!
    public private(set) var rates: Dictionary<String, Double>!
    public private(set) var date: Date!
    
    public private(set) var isFetching: Bool = false
    
    public var isLastFetchOlderThanAnHour: Bool {
        if date == nil {
            return true
        }
        
        let now = Date()
        let intervalSinceLastFetch = now.timeIntervalSince(self.date)
        if intervalSinceLastFetch >= 3600.0 {
            return true
        } else {
            return false
        }
    }
    
    public func calculateExchangeRate(_ fromCode: String, toCode: String) -> Double {
        let fromToBaseRate = rates[fromCode]!
        let toToBaseRate = rates[toCode]!
        return toToBaseRate / fromToBaseRate
    }
    
    public func exchangeRate(_ fromCode: String, toCode: String, completionHandler: (fromCode: String, toCode: String, exchangeRate: NSNumber?, error: NSError?) -> ()) {
        let thisOperationQueue = OperationQueue.current!
        if isLastFetchOlderThanAnHour {
            fetchFromOpenExchangeRates({ (baseCurrency, rates, error) -> () in
                if error != nil {
                    completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: nil, error: error)
                    return
                }
                let exchangeRate = self.calculateExchangeRate(fromCode, toCode: toCode)
                thisOperationQueue.addOperation({ () -> Void in
                    completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: exchangeRate, error: nil)
                })
            })
        } else {
            let rate = calculateExchangeRate(fromCode, toCode: toCode)
            completionHandler(fromCode: fromCode, toCode: toCode, exchangeRate: rate, error: nil)
        }
    }
    
    public func fetchFromOpenExchangeRates(_ completionHandler: (baseCurrency: String?, rates: Dictionary<String, Double>?, error: NSError?) -> ()) {
        if isFetching {
            let error = NSError(domain: "ExchangeRateFetcher", code: 1, userInfo: ["reason": "Already fetching"])
            completionHandler(baseCurrency: nil, rates: nil, error: error)
            return
        }
        isFetching = true
        UIApplication.shared().isNetworkActivityIndicatorVisible = true
        
        let url = URL(string: "https://openexchangerates.org/api/latest.json?app_id=cba02a60bd89412095c84ecb65b6326a");
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            UIApplication.shared().isNetworkActivityIndicatorVisible = false
            if error != nil {
                print("Error fetching exchangeRate from OpenExchangeRates: \(error)")
                OperationQueue.main.addOperation({ () -> Void in
                    completionHandler(baseCurrency: nil, rates: nil, error: error)
                    self.isFetching = false
                })
                return
            }
            
            let httpResp = response as! HTTPURLResponse
            if (httpResp.statusCode == 200) {
                do {
                    let jsonResponseDictonary = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String, AnyObject>
                    let baseCurrencyCode = jsonResponseDictonary["base"] as? String
                    let rates = jsonResponseDictonary["rates"] as? Dictionary<String, Double>
                    let date = Date(timeIntervalSince1970: Double((jsonResponseDictonary["timestamp"] as? Int)!))
                    OperationQueue.main.addOperation({ () -> Void in
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
                    OperationQueue.main.addOperation({ () -> Void in
                        completionHandler(baseCurrency: nil, rates: nil, error: jsonError)
                        self.isFetching = false
                    })
                }
            } else {
                // Status code != 200
                let error = NSError(domain: "ExchangeRateFetcher", code: 2, userInfo: ["reason": "HTTP Response code: \(httpResp)", "response": httpResp])
                OperationQueue.main.addOperation({ () -> Void in
                    completionHandler(baseCurrency: nil, rates: nil, error: error)
                    self.isFetching = false
                })
            }
        }
        task.resume()
    }
    
    public func isCurrencyCodeAvailableInRates(_ code: String) -> Bool {
        if let _ = rates[code] {
            return true
        } else {
            print("CurrencyCode: \(code) not present.")
            return false
        }
    }
    
    public subscript(code: String) -> Double {
        return rates[code]!
    }
}
