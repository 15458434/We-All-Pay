//
//  MultiExchangeRatesController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 12/01/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Cocoa

class MultiExchangeRatesController: NSObject {
    dynamic var exchangeRates = [ExchangeRatesForSum]()
    
    dynamic var availableXRates: [MCxRatesCurrency]
    
    override init() {
        availableXRates = NSArray(array: MCxRatesController.getAllCurrencies(), copyItems: true) as [MCxRatesCurrency]
        super.init()
    }
    
    func fetchCurrencyNames() -> [String] {
        return availableXRates.map {
            return $0.fullCurrencyName
        }
    }
    
    func fetchCurrency(#ISOcode: String) -> MCxRatesCurrency {
        let arrayWithResult = availableXRates.filter {
            return $0.currencyISOCode == ISOcode
        }
        return arrayWithResult.first!
    }
    
    func doesCurrencyExist(#ISOcode: String) -> Bool {
        let arrayWithResult = availableXRates.filter {
            return $0.currencyISOCode == ISOcode
        }
        if arrayWithResult.count == 0 {
            return false
        } else {
            return true
        }
    }
    
    func sumInMainCurrency() -> Double {
        return exchangeRates.reduce(0) {
            $0 + $1.valueInMainCurrency
        }
    }
}
