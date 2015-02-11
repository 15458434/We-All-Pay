//
//  MultipleCurrencyInterface.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/01/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Cocoa

class MultipleCurrencyInterfaceController : NSWindowController, NSTableViewDelegate {
    private var editExchangeRateWindow: EditValueInCurrencyWindowController?
    
    @IBOutlet var multiExchangeRateController: MultiExchangeRatesController! = MultiExchangeRatesController.sharedController()
    
    @IBAction func refreshExchangeRatesPressed(sender: AnyObject) {
        println("Refreshing love it")
    }
    
    @IBOutlet var destinationCurrencyPopUpButtonArrayController: NSArrayController!
    @IBOutlet weak var destinationCurrencyPopUpButton: NSPopUpButton!
    @IBOutlet weak var destinationCurrencyLabel: NSTextField!
    @IBOutlet weak var destinationCurrencyNumberFormatter: NSNumberFormatter!
    
    @IBOutlet var exchangeRatesForSumArrayController: NSArrayController!
    
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var editButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    
    // MARK: IBActions
    @IBAction func newDestinationCurrencySelected(sender: AnyObject) {
        if sender as NSObject == destinationCurrencyPopUpButton {
            let selectedCurrency = getSelectedDestinationCurrency()
            debugLog("\(selectedCurrency.currencyName)(\(selectedCurrency.currencySymbol))")
            multiExchangeRateController.updateDestinationCurrency(currency: selectedCurrency)
            destinationCurrencyNumberFormatter.currencyCode = selectedCurrency.currencyISOCode
        }
    }
    
    @IBAction func editExchangeRateForSumPressed(sender: AnyObject) {
        if (sender as NSObject == editButton) {
            editExchangeRateWindow = EditValueInCurrencyWindowController(windowNibName: "EditValueInCurrencyWindow")
            editExchangeRateWindow?.exchangeRate = getSelectedExchange()
            editExchangeRateWindow?.showWindow(self)
            editExchangeRateWindow?.window?.makeKeyAndOrderFront(self)
        } 
    }
    
    func getSelectedDestinationCurrency() -> MCxRatesCurrency! {
        return destinationCurrencyPopUpButtonArrayController.selectedObjects!.first! as MCxRatesCurrency
    }
    
    // MARK: This class
    func getSelectedExchange() -> ExchangeRatesForSum? {
        return exchangeRatesForSumArrayController.selectedObjects?.first as? ExchangeRatesForSum
    }
    
    // MARK: NSTableViewDelegate
    func tableViewSelectionDidChange(notification: NSNotification) {
        if notification.name == NSTableViewSelectionDidChangeNotification {
            let exchangeRateData = getSelectedExchange()
            if let exchangeRate = exchangeRateData {
                editButton.enabled = true
                removeButton.enabled = true
            } else {
                editButton.enabled = false
                removeButton.enabled = false
            }
        }
    }
}
