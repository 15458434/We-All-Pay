//
//  CurrencyModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 25/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import UIKit
import CoreData
import os
import CurrencyConverter

@objc(MCCurrencyModel) final class CurrencyModel: NSObject {
    enum Error: Swift.Error {
        case noCurrencyCode
    }
    private let managedObjectContext: NSManagedObjectContext
    private let currencyController: CurrencyController
    private let logger: Logger
    
    @objc(initWithManagedObjectContext:andWithCurrencyController:) init(managedObjectContext: NSManagedObjectContext, currencyController: CurrencyController) {
        self.managedObjectContext = managedObjectContext
        self.currencyController = currencyController
        self.logger = Logger(category: "CurrencyModel")
        super.init()
    }
    
    @objc(generateCurrencyFromSelectedLocaleWithError:) func generateCurrencyFromSelectedLocale() throws -> MCCurrency {
        let currencyCodeFromCurrentLocale: String?
        if #available(iOS 16, *) {
            currencyCodeFromCurrentLocale = Locale.current.currency?.identifier
        } else {
            currencyCodeFromCurrentLocale = Locale.current.currencyCode
        }
        guard let currencyCodeFromCurrentLocale else {
            throw Error.noCurrencyCode
        }
        let currencyNameFromCurrentLocale = WeAllPayStoreController.defaultStore.fetcher.currencyController.currencySymbol(currencyCodeFromCurrentLocale)
        let currencySymbolFromCurrentLocale = WeAllPayStoreController.defaultStore.fetcher.currencyController.currencySymbol(currencyCodeFromCurrentLocale)
        let newCurrency = MCCurrency(context: managedObjectContext)
        newCurrency.code = currencyCodeFromCurrentLocale
        newCurrency.name = currencyNameFromCurrentLocale
        newCurrency.symbol = currencySymbolFromCurrentLocale
        newCurrency.isStillValid = true as NSNumber
        return newCurrency
    }
    
    @objc(currencyFromCurrencyCode:) func currency(from code: String) -> MCCurrency {
        let new = MCCurrency(context: managedObjectContext)
        new.name = currencyController[code]
        new.symbol = currencyController.currencySymbol(code)
        new.code = code
        new.isStillValid = true as NSNumber
        return new
    }
}
