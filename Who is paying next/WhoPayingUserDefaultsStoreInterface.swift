//
//  WhoPayingUserDefaultsStoreInterface.swift
//  We all pay
//
//  Created by Mark Cornelisse on 04/12/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

private let kTonightsBillUUID = "MCTonightsBillUUIDKey"
private let kTripName = "MCTripNameKey"
private let kNextPayerUUID = "MCNextPayerUUIDKey"
private let kFullNameOfNextPayer = "MCFullNameOfNextPayerKey"
private let kValid = "MCIsTodayExchangeValidKey"
private let kDateSaved = "MCDateSavedKey"

public class WhoPayingUserDefaultsStoreInterface: NSObject {
    // MARK: Properties
    public var tonightsBillUUID: String?
    public var tripName: String?
    
    public var nextPayerUUID: String?
    public var fullNameOfNextPayer: String?
    
    public var valid: Bool {
        if ((self.tonightsBillUUID != nil) && (self.tripName != nil) && (self.nextPayerUUID != nil) && (fullNameOfNextPayer != nil)) {
            return true
        } else {
            return false
        }
    }
    
    public var dateSaved: NSDate!
    
    private var defaults: NSUserDefaults {
        return NSUserDefaults(suiteName: WhoPayingUserDefaultsStoreInterface.MCWeAllPayToWhoIsPayingNextGroupBundleIdentifier)!
    }
    
    public static let MCWhoIsPayingNextBundleIdentifier: String = "group.com.GreenHair.We-all-pay.Who-is-paying-next"
    public static let MCWeAllPayToWhoIsPayingNextGroupBundleIdentifier: String = "group.com.GreenHair.We-all-pay.Who-is-paying-next"
    
    public override init() {
        super.init()
        self.fetchFromUserDefaults()
    }
    
    public init(tonightsBillUUID: String?, tripName: String?, nextPayerUUID: String?, fullNameOfNextPayer: String?) {
        self.tonightsBillUUID = tonightsBillUUID
        self.tripName = tripName
        self.nextPayerUUID = nextPayerUUID
        self.fullNameOfNextPayer = fullNameOfNextPayer
        super.init()
    }
    
    public func fetchFromUserDefaults() {
        tonightsBillUUID = defaults.objectForKey(kTonightsBillUUID) as? String
        tripName = defaults.objectForKey(kTripName) as? String
        nextPayerUUID = defaults.objectForKey(kNextPayerUUID) as? String
        fullNameOfNextPayer = defaults.objectForKey(kFullNameOfNextPayer) as? String
        dateSaved = defaults.objectForKey(kDateSaved) as? NSDate
    }
    
    public func storeToDefaults() {
        defaults.setObject(tonightsBillUUID, forKey: kTonightsBillUUID)
        defaults.setObject(tripName, forKey: kTripName)
        defaults.setObject(nextPayerUUID, forKey: kNextPayerUUID)
        defaults.setObject(fullNameOfNextPayer, forKey: kFullNameOfNextPayer)
        self.dateSaved = NSDate()
        defaults.setObject(dateSaved, forKey: kDateSaved)
        defaults.synchronize()
    }
}