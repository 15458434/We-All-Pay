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
    
    dynamic var destinationValue: Double = 0.00
    dynamic var destinationCurrencyCode: String = "" {
        willSet {
            self.willChangeValueForKey("destinationValue")
        }
        didSet {
            self.didChangeValueForKey("destinationValue")
        }
    }
    
    dynamic var availableXRates: [MCxRatesCurrency]
    
    class func sharedController() -> MultiExchangeRatesController {
        // SingleTonStuff
        return globalSharedInstance
    }
    
    private override init() {
        availableXRates = NSArray(array: MCxRatesController.getAllCurrencies(), copyItems: true) as [MCxRatesCurrency]
        super.init()
    }
    
    // MARK: New in this class
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
    
    func updateDestinationCurrency(#currency: MCxRatesCurrency) {
        destinationCurrencyCode = currency.currencyISOCode
    }
    
    var numberFormatter: NSNumberFormatter {
        // Gives a numberformatter based on the currencyCode property of this class.
        let nf = NSNumberFormatter()
        nf.locale = NSLocale.currentLocale()
        nf.numberStyle = .CurrencyStyle
        nf.currencyCode = destinationCurrencyCode
        return nf
    }
    
    // MARK: NSObjectProtocol
    override func setNilValueForKey(key: String) {
        switch key {
        case "destinationValue":
            destinationValue = 0.0
        default:
            println("Nothing should happen.")
        }
    }
}

// Don't use outside this file.
private let globalSharedInstance = MultiExchangeRatesController()

