//
//  WhoPayingUserDefaultsStoreInterfaceWeAllPayExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 04/12/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation
import WhoPayingUserDefaultsStoreInterface

extension WhoPayingUserDefaultsStoreInterface {
    @objc class func sendToUserDefaultsStoreInterface(_ tonightsBill: MCSharedBill?) {
        // Get data in local variables.
        let billID = tonightsBill?.uniqueBillId
        let tripName = tonightsBill?.tripName
        let nextPayer = tonightsBill?.fetchPeoplePresentOrdered(byAmountPaid: true).first
        let nextPayerID = nextPayer?.uniquePersonId
        let nextPayerName = nextPayer?.getFullName()
        
        // Put it in a backgroundQueue
        let backgroundQueue = DispatchQueue(label: "sendToWhoIsPayingNextQueue", attributes: [])
        backgroundQueue.async { () -> Void in
            let storeInterface = WhoPayingUserDefaultsStoreInterface(tonightsBillUUID: billID, tripName: tripName, nextPayerUUID: nextPayerID, fullNameOfNextPayer: nextPayerName)
            storeInterface.storeToDefaults()
        }
    }
    
    @objc class func sendInvalidUserDefaultsIfTonightsBillIs(_ tonightsBill: MCSharedBill?) {
        let currentStoreInterfaceContents = WhoPayingUserDefaultsStoreInterface()
        if tonightsBill?.uniqueBillId == currentStoreInterfaceContents.tonightsBillUUID {
            WhoPayingUserDefaultsStoreInterface.sendToUserDefaultsStoreInterface(nil)
        }
    }
}
