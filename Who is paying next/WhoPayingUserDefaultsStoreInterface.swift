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
    
    public var dateSaved: Date!
    
    private var defaults: UserDefaults {
        return UserDefaults(suiteName: WhoPayingUserDefaultsStoreInterface.MCWeAllPayToWhoIsPayingNextGroupBundleIdentifier)!
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
        tonightsBillUUID = defaults.object(forKey: kTonightsBillUUID) as? String
        tripName = defaults.object(forKey: kTripName) as? String
        nextPayerUUID = defaults.object(forKey: kNextPayerUUID) as? String
        fullNameOfNextPayer = defaults.object(forKey: kFullNameOfNextPayer) as? String
        dateSaved = defaults.object(forKey: kDateSaved) as? Date
    }
    
    public func storeToDefaults() {
        defaults.set(tonightsBillUUID, forKey: kTonightsBillUUID)
        defaults.set(tripName, forKey: kTripName)
        defaults.set(nextPayerUUID, forKey: kNextPayerUUID)
        defaults.set(fullNameOfNextPayer, forKey: kFullNameOfNextPayer)
        self.dateSaved = Date()
        defaults.set(dateSaved, forKey: kDateSaved)
        defaults.synchronize()
    }
}
