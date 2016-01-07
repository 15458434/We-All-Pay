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
    class func sendToUserDefaultsStoreInterface(tonightsBill: MCSharedBill?) {
        // Get data in local variables.
        let billID = tonightsBill?.uniqueBillId
        let tripName = tonightsBill?.tripName
        let nextPayer = tonightsBill?.fetchPeoplePresentOrderedByAmountPaid(true).first as? MCPerson
        let nextPayerID = nextPayer?.uniquePersonId
        let nextPayerName = nextPayer?.getFullName()
        
        // Put it in a backgroundQueue
        let backgroundQueue = dispatch_queue_create("sendToWhoIsPayingNextQueue", nil)
        dispatch_async(backgroundQueue) { () -> Void in
            let storeInterface = WhoPayingUserDefaultsStoreInterface(tonightsBillUUID: billID, tripName: tripName, nextPayerUUID: nextPayerID, fullNameOfNextPayer: nextPayerName)
            storeInterface.storeToDefaults()
        }
    }
    
    class func sendInvalidUserDefaultsIfTonightsBillIs(tonightsBill: MCSharedBill?) {
        let currentStoreInterfaceContents = WhoPayingUserDefaultsStoreInterface()
        if tonightsBill?.uniqueBillId == currentStoreInterfaceContents.tonightsBillUUID {
            WhoPayingUserDefaultsStoreInterface.sendToUserDefaultsStoreInterface(nil)
        }
    }
}