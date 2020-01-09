//
//  AdEngine.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit
import AdSupport

import PersonalizedAdConsent
import GoogleMobileAds

@objcMembers class AdEngine: NSObject {
    class func registerDebugDevices() {
        let iPhoneX = "3a960c027f1ea390326793600324a891"
        let iPadRetina = "63f51db641e29b85012042e407de3cba"
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String), iPhoneX, iPadRetina]
    }
}
