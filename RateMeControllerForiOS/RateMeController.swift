//
//  RateMeController.swift
//  RateMeForOSX
//
//  Created by Mark Cornelisse on 12/01/16.
//  Copyright © 2016 Over de muur producties. All rights reserved.
//

import Foundation

internal let rateMeControllerCounterInterval: Int = 3
internal let rateMeControllerMinimumTimeIntervalInDays: Double = 7.0
internal let rateMeControllerTimeIntervalInDays: Double = 21.0

//private let rateMeControllerOneDayTimeInterval: Double = 1
private let rateMeControllerOneDayTimeInterval: Double = 86400


private let kRateMeControllerFirstLaunchDate = "kFirstLaunchDate"
private let kRateMeControllerCounterValue = "kRateMeControllerCounterValue"
private let kRateMeControllerShouldAskContainer = "kRateMeControllerAskStatus"

public class RateMeController: NSObject {
    // MARK: Properties
    private let firstLaunchDate: NSDate
    private var currentDate = NSDate()
    private var counterValue: Int
    private var shouldAskContainer: RateMeControllerAskStatusContainer
    
    private var currentVersionString = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
    
    // MARK: New in this class
    
    internal class func reset() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kRateMeControllerFirstLaunchDate)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kRateMeControllerCounterValue)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kRateMeControllerShouldAskContainer)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public var shouldDisplayRateMeQuestion: Bool {
        counterValue += 1
        let currentTimeIntervalInDays = self.currentDate.timeIntervalSinceDate(firstLaunchDate) / rateMeControllerOneDayTimeInterval
        debugPrint("CurrentTimeIntervalInDays: \(currentTimeIntervalInDays)")
        debugPrint("CounterValue: \(counterValue)")
        switch (shouldAskContainer.shouldAsk) {
        case .NoNever:
            return false
        case .Yes:
            switch (currentTimeIntervalInDays, counterValue) {
            case let (t, _) where t < rateMeControllerMinimumTimeIntervalInDays:
                return false
            case let (t, i) where t >= rateMeControllerMinimumTimeIntervalInDays && i > rateMeControllerCounterInterval:
                return true
            case let (t, _) where t > rateMeControllerTimeIntervalInDays:
                return true
            default:
                return false
            }
        case .AlreadyRated:
            if shouldAskContainer.lastVersion != currentVersionString {
                return true
            } else {
                return false
            }
        case .No:
            if shouldAskContainer.lastVersion != currentVersionString {
                return true
            } else {
                return false
            }
        }
    }
    
    public func rateMeDisplayed(shouldAskAgain: RateMeControllerAskStatus) {
        shouldAskContainer.shouldAsk = shouldAskAgain
        switch (shouldAskAgain) {
        case .No:
            shouldAskContainer.lastVersion = currentVersionString
        case .AlreadyRated:
            shouldAskContainer.lastVersion = currentVersionString
        case .Yes:
            counterValue = 0
            shouldAskContainer.lastVersion = nil
        case .NoNever:
            shouldAskContainer.lastVersion = nil
        }
    }
    
    internal init(firstDate: NSDate, counterValue: Int, shouldAsk: RateMeControllerAskStatusContainer) {
        self.firstLaunchDate = firstDate
        self.counterValue = counterValue
        self.shouldAskContainer = shouldAsk
        super.init()
    }
    
    public func save() -> Bool {
        NSUserDefaults.standardUserDefaults().setObject(self.firstLaunchDate, forKey: kRateMeControllerFirstLaunchDate)
        NSUserDefaults.standardUserDefaults().setInteger(self.counterValue, forKey: kRateMeControllerCounterValue)
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(self.shouldAskContainer), forKey: kRateMeControllerShouldAskContainer)
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: Inherited from super
    
    public override init() {
        if let firstLaunchDateForUserDefaults = NSUserDefaults.standardUserDefaults().objectForKey(kRateMeControllerFirstLaunchDate) as? NSDate {
            self.firstLaunchDate = firstLaunchDateForUserDefaults
        } else {
            self.firstLaunchDate = NSDate()
        }
        
        self.counterValue = NSUserDefaults.standardUserDefaults().integerForKey(kRateMeControllerCounterValue)
        if let shouldAskContainerData = NSUserDefaults.standardUserDefaults().objectForKey(kRateMeControllerShouldAskContainer) as? NSData {
            if let userDefaultShouldAsk = NSKeyedUnarchiver.unarchiveObjectWithData(shouldAskContainerData) as? RateMeControllerAskStatusContainer {
                self.shouldAskContainer = userDefaultShouldAsk
            } else {
                self.shouldAskContainer = RateMeControllerAskStatusContainer()
            }
        } else {
            self.shouldAskContainer = RateMeControllerAskStatusContainer()
        }
        
        super.init()
    }
}