//
//  ExchangeRateFetcherForMCExchangeRate.swift
//  We all pay
//
//  Created by Mark Cornelisse on 15/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation
import CurrencyConverter

extension ExchangeRateFetcher {
    private func update(_ exchangeRates: [MCExchangeRate]) {
        for exchangeRate in exchangeRates {
            let fromCode = exchangeRate.fromCurrency.code
            let toCode = exchangeRate.toCurrency.code
            let newExchangeRate = calculateExchangeRate(fromCode!, toCode: toCode!)
            exchangeRate.exchangeRate = NSNumber(value: newExchangeRate)
            exchangeRate.status = NSNumber(value: MCExchangeRateStatus.valid.rawValue)
        }
    }
    
    func fetchAll(_ exchangeRates: [MCExchangeRate], completionHandler: ((error: NSError?) -> ())) {
        if isLastFetchOlderThanAnHour {
            fetchFromOpenExchangeRates({ (baseCurrency, rates, error) -> () in
                if error != nil {
                    completionHandler(error: error)
                    return
                }
                
                self.update(exchangeRates)
                completionHandler(error: nil)
            })
        } else {
            update(exchangeRates)
            completionHandler(error: nil)
        }
    }
}
