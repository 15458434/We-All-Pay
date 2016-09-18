//
//  LaunchCounter.swift
//  We all pay
//
//  Created by Mark Cornelisse on 18/09/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import Foundation

private let kLaunchCounterValue: String = "kLaunchCounterValue"

@objc(MCLaunchCounter) class LaunchCounter: NSObject {
    private var value: UInt64?
    var count: UInt64 {
        if let value = self.value {
            return value
        } else {
            let ud = UserDefaults.standard
            let number = ud.value(forKey: kLaunchCounterValue) as? NSNumber
            let value = number?.uint64Value ?? 0
            return value
        }
    }
    
    func increment() -> UInt64 {
        value = count + 1
        let ud = UserDefaults.standard
        ud.setValue(NSNumber.init(value: value!), forKey: kLaunchCounterValue)
        _ = ud.synchronize()
        return count
    }
    
    func reset() {
        let ud = UserDefaults.standard
        ud.setValue(nil, forKey: kLaunchCounterValue)
    }
}
