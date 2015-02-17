//
//  ExchangeRates.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/01/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

enum ExchangeRateForSumState {
    case Invalid
    case Fetching
    case Valid
}

@objc(ExchangeRatesForSum)
class ExchangeRatesForSum: NSObject {
    dynamic private(set) var valueInMainCurrency: Double = 0.0
    dynamic var valueInCurrency: Double = 0.0
    dynamic var exchangeRateToDestinationCurrency: Double = 0.0
    
    dynamic var currencyCode: String?
    dynamic var currencyName: String?
    dynamic var currencySymbol: String?
    
    var exchangeRateState: ExchangeRateForSumState
    dynamic var uniqueID: String? = NSUUID().UUIDString
    dynamic var dateCreated: NSDate? = NSDate()
    
    // MARK: Initializers
    init(code: String) {
        exchangeRateState = ExchangeRateForSumState.Invalid
        super.init()
    }
    
    // MARK: This class
//    var numberFormatter: NSNumberFormatter {
//        // Gives a numberformatter based on the currencyCode property of this class.
//        let nf = NSNumberFormatter()
//        nf.locale = NSLocale.currentLocale()
//        nf.numberStyle = .CurrencyStyle
//        nf.currencyCode = currencyCode!
//        return nf
//    }
    
    // MARK: NSObjectProtocol
    
    override init() {
        exchangeRateState = ExchangeRateForSumState.Invalid
        super.init()
    }
    
    override func setNilValueForKey(key: String) {
        switch key {
        case "valueInCurrency":
            valueInCurrency = 0.0
        case "exchangeRateToDestinationCurrency":
            exchangeRateToDestinationCurrency = 0.0
        default:
            println("Nothing should happen.")
        }
    }
}
