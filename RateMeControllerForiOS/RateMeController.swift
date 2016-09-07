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
    private let firstLaunchDate: Date
    private var currentDate = Date()
    private var counterValue: Int
    private var shouldAskContainer: RateMeControllerAskStatusContainer
    
    private var currentVersionString = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    
    // MARK: New in this class
    
    internal class func reset() {
        UserDefaults.standard.removeObject(forKey: kRateMeControllerFirstLaunchDate)
        UserDefaults.standard.removeObject(forKey: kRateMeControllerCounterValue)
        UserDefaults.standard.removeObject(forKey: kRateMeControllerShouldAskContainer)
        UserDefaults.standard.synchronize()
    }
    
    public var shouldDisplayRateMeQuestion: Bool {
        counterValue += 1
        let currentTimeIntervalInDays = self.currentDate.timeIntervalSince(firstLaunchDate) / rateMeControllerOneDayTimeInterval
        debugPrint("CurrentTimeIntervalInDays: \(currentTimeIntervalInDays)")
        debugPrint("CounterValue: \(counterValue)")
        switch (shouldAskContainer.shouldAsk) {
        case .noNever:
            return false
        case .yes:
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
        case .alreadyRated:
            if shouldAskContainer.lastVersion != currentVersionString {
                return true
            } else {
                return false
            }
        case .no:
            if shouldAskContainer.lastVersion != currentVersionString {
                return true
            } else {
                return false
            }
        }
    }
    
    public func rateMeDisplayed(_ shouldAskAgain: RateMeControllerAskStatus) {
        shouldAskContainer.shouldAsk = shouldAskAgain
        switch (shouldAskAgain) {
        case .no:
            shouldAskContainer.lastVersion = currentVersionString
        case .alreadyRated:
            shouldAskContainer.lastVersion = currentVersionString
        case .yes:
            counterValue = 0
            shouldAskContainer.lastVersion = nil
        case .noNever:
            shouldAskContainer.lastVersion = nil
        }
    }
    
    internal init(firstDate: Date, counterValue: Int, shouldAsk: RateMeControllerAskStatusContainer) {
        self.firstLaunchDate = firstDate
        self.counterValue = counterValue
        self.shouldAskContainer = shouldAsk
        super.init()
    }
    
    public func save() -> Bool {
        UserDefaults.standard.set(self.firstLaunchDate, forKey: kRateMeControllerFirstLaunchDate)
        UserDefaults.standard.set(self.counterValue, forKey: kRateMeControllerCounterValue)
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self.shouldAskContainer), forKey: kRateMeControllerShouldAskContainer)
        return UserDefaults.standard.synchronize()
    }
    
    // MARK: Inherited from super
    
    public override init() {
        if let firstLaunchDateForUserDefaults = UserDefaults.standard.object(forKey: kRateMeControllerFirstLaunchDate) as? Date {
            self.firstLaunchDate = firstLaunchDateForUserDefaults
        } else {
            self.firstLaunchDate = Date()
        }
        
        self.counterValue = UserDefaults.standard.integer(forKey: kRateMeControllerCounterValue)
        if let shouldAskContainerData = UserDefaults.standard.object(forKey: kRateMeControllerShouldAskContainer) as? Data {
            if let userDefaultShouldAsk = NSKeyedUnarchiver.unarchiveObject(with: shouldAskContainerData) as? RateMeControllerAskStatusContainer {
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
