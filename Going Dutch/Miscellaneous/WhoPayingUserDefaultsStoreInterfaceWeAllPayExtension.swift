//
//  WhoPayingUserDefaultsStoreInterfaceWeAllPayExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 04/12/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation
import WhoPayingUserDefaultsStoreInterface
import CurrencyConverter

extension WhoPayingUserDefaultsStoreInterface {
    @objc class func sendToUserDefaultsStoreInterface(_ event: MCSharedBill?) {
        // Get data in local variables.
        if let event {
            let currencyController = CurrencyController()
            let currencyModel = CurrencyModel(managedObjectContext: event.managedObjectContext!, currencyController: currencyController)
            let eventModel = EventModel(event: event, currencyModel: currencyModel)
            
            let billID = event.uniqueBillId
            let tripName = event.tripName
            
            let nextPayer = eventModel.nextPayer
            let nextPayerID = nextPayer?.uniquePersonId
            let nextPayerName = nextPayer?.fullName
            
            // Put it in a backgroundQueue
            let backgroundQueue = DispatchQueue(label: "sendToWhoIsPayingNextQueue", attributes: [])
            backgroundQueue.async { () -> Void in
                let storeInterface = WhoPayingUserDefaultsStoreInterface(tonightsBillUUID: billID, tripName: tripName, nextPayerUUID: nextPayerID, fullNameOfNextPayer: nextPayerName)
                storeInterface.storeToDefaults()
            }
        } else {
            // Put it in a backgroundQueue
            let backgroundQueue = DispatchQueue(label: "sendToWhoIsPayingNextQueue", attributes: [])
            backgroundQueue.async { () -> Void in
                let storeInterface = WhoPayingUserDefaultsStoreInterface(tonightsBillUUID: nil, tripName: nil, nextPayerUUID: nil, fullNameOfNextPayer: nil)
                storeInterface.storeToDefaults()
            }
        }
    }
    
    @objc class func sendInvalidUserDefaultsIfTonightsBillIs(_ tonightsBill: MCSharedBill?) {
        let currentStoreInterfaceContents = WhoPayingUserDefaultsStoreInterface()
        if tonightsBill?.uniqueBillId == currentStoreInterfaceContents.tonightsBillUUID {
            WhoPayingUserDefaultsStoreInterface.sendToUserDefaultsStoreInterface(nil)
        }
    }
}
