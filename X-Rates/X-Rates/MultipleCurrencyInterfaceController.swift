//
//  MultipleCurrencyInterface.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/01/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Cocoa

class MultipleCurrencyInterfaceController : NSWindowController {
    @IBOutlet var multiExchangeRateController: MultiExchangeRatesController! = MultiExchangeRatesController()
    
    @IBAction func refreshExchangeRatesPressed(sender: AnyObject) {
        println("Refreshing love it")
    }
    
    @IBOutlet var destinationCurrencyPopUpButtonArrayController: NSArrayController!
    @IBOutlet weak var destinationCurrencyPopUpButton: NSPopUpButton!
    @IBOutlet weak var destinationCurrencyLabel: NSTextField!
    @IBOutlet weak var destinationCurrencyNumberFormatter: NSNumberFormatter!
    
    @IBAction func newDestinationCurrencySelected(sender: AnyObject) {
        if sender as NSObject == destinationCurrencyPopUpButton {
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
