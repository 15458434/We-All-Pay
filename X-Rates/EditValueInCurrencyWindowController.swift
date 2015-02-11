//
//  EditValueInCurrencyWindowController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 10/02/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Cocoa

class EditValueInCurrencyWindowController: NSWindowController {
    @IBOutlet var multiExchangeRateController: MultiExchangeRatesController! = MultiExchangeRatesController.sharedController()
    var exchangeRate: ExchangeRatesForSum!
    
    @IBOutlet var currencyPopUpArrayController: NSArrayController!
    @IBOutlet weak var currencyPopUpButton: NSPopUpButton!
    @IBOutlet weak var AmountOfCurrencyTextField: NSTextField!
    
    @IBOutlet weak var amountNumberFormatter: NSNumberFormatter!
    
    // MARK: IBActions
    @IBAction func newCurrencySelected(sender: AnyObject) {
        if sender as NSObject == currencyPopUpButton {
            let selectedCurrency = getSelectedCurrency()
            updateExchangeRate(currency: selectedCurrency)
        }
    }
    
    private func getSelectedCurrency() -> MCxRatesCurrency! {
        return currencyPopUpArrayController.selectedObjects!.first! as MCxRatesCurrency
    }
    
    private func updateExchangeRate(#currency: MCxRatesCurrency) {
        debugLog("\(currency.currencyName) (\(currency.currencyISOCode))")
        exchangeRate.currencyCode = currency.currencyISOCode
        exchangeRate.currencyName = currency.currencyName
        exchangeRate.currencySymbol = currency.currencySymbol
    }
}