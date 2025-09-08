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
            let fromCode = exchangeRate.fromCurrency!.code!
            let toCode = exchangeRate.toCurrency!.code!
            let newExchangeRate = calculateExchangeRate(fromCode, toCode: toCode)
            exchangeRate.exchangeRate = newExchangeRate
            exchangeRate.status = NSNumber(value: MCExchangeRateStatus.valid.rawValue)
        }
    }
    
    @objc func fetchAll(_ exchangeRates: [MCExchangeRate], completionHandler: @escaping ((_ error: NSError?) -> ())) {
        if isLastFetchOlderThanAnHour {
            fetchFromOpenExchangeRates({ (baseCurrency, rates, error) -> () in
                if error != nil {
                    completionHandler(error)
                    return
                }
                
                self.update(exchangeRates)
                completionHandler(nil)
            })
        } else {
            update(exchangeRates)
            completionHandler(nil)
        }
    }
}
