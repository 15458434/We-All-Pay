//
//  ExchangeRateFetcher.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc public final class ExchangeRateFetcher: NSObject {
    @objc public let currencyController: CurrencyController = CurrencyController()
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
    
    @objc public func exchangeRate(_ fromCode: String, toCode: String, completionHandler: @escaping (_ fromCode: String, _ toCode: String, _ exchangeRate: NSNumber?, _ error: NSError?) -> ()) {
        let thisOperationQueue = OperationQueue.current!
        if isLastFetchOlderThanAnHour {
            fetchFromOpenExchangeRates({ (baseCurrency, rates, error) -> () in
                if error != nil {
                    completionHandler(fromCode, toCode, nil, error)
                    return
                }
                let exchangeRate = self.calculateExchangeRate(fromCode, toCode: toCode)
                thisOperationQueue.addOperation({ () -> Void in
                    completionHandler(fromCode, toCode, exchangeRate as NSNumber?, nil)
                })
            })
        } else {
            let rate = calculateExchangeRate(fromCode, toCode: toCode)
            completionHandler(fromCode, toCode, rate as NSNumber?, nil)
        }
    }
    
    public func fetchFromOpenExchangeRates(_ completionHandler: @escaping (_ baseCurrency: String?, _ rates: Dictionary<String, Double>?, _ error: NSError?) -> ()) {
        if isFetching {
            let error = NSError(domain: "ExchangeRateFetcher", code: 1, userInfo: ["reason": "Already fetching"])
            completionHandler(nil, nil, error)
            return
        }
        isFetching = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = URL(string: "https://openexchangerates.org/api/latest.json?app_id=cba02a60bd89412095c84ecb65b6326a");
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            DispatchQueue.main.sync {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            guard error == nil else {
                debugPrint("Error fetching exchangeRate from OpenExchangeRates: \(String(describing: error))")
                OperationQueue.main.addOperation({ () -> Void in
                    completionHandler(nil, nil, error as NSError?)
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
                        completionHandler(baseCurrencyCode, rates, nil)
                            self.isFetching = false
                    })
                } catch let error {
                    // JSON Error
                    print("Error reading exchangeRatesFromJSON: \(error)")
                    let jsonError = NSError(domain: "We all pay", code: 0, userInfo: ["Reason": "Error parsing json"])
                    OperationQueue.main.addOperation({ () -> Void in
                        completionHandler(nil, nil, jsonError)
                        self.isFetching = false
                    })
                }
            } else {
                // Status code != 200
                let error = NSError(domain: "ExchangeRateFetcher", code: 2, userInfo: ["reason": "HTTP Response code: \(httpResp)", "response": httpResp])
                OperationQueue.main.addOperation({ () -> Void in
                    completionHandler(nil, nil, error)
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
