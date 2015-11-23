//
//  ADoriginate.swift
//  We all pay
//
//  Created by Mark Cornelisse on 30/12/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

import Foundation
import iAd


class ADoriginate : NSObject {
    let fromiAdKey = "fromiAdBoolKey"
    var fromiAd: NSNumber?
    
    override init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        fromiAd = userDefaults.boolForKey(fromiAdKey)
        
        super.init()
    }
    
    init(completionHandler: () -> ()) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let fromiAdValueFromUserDefaults: Bool! = userDefaults.boolForKey(fromiAdKey)
        if let myValue = fromiAdValueFromUserDefaults {
            fromiAd = NSNumber(bool: myValue)
        }
        
        super.init()
        if fromiAd != nil {
            fetchAttribution({ () -> () in
                completionHandler()
            })
        } else {
            completionHandler()
        }
    }
    
    func fetchAttribution(completionHandler: () -> ()){
        ADClient.sharedClient().lookupAdConversionDetails({ (appPurchaseDate, iAdImpressionDate) -> Void in
            // True if we were installed from an iAd campaign
            if iAdImpressionDate != nil {
                self.fromiAd = true
            } else {
                self.fromiAd = false
            }
            completionHandler()
            self.save()
        })
    }
    
    func save() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let fromiAdValue = fromiAd?.boolValue {
            userDefaults.setBool(fromiAdValue, forKey: fromiAdKey)
            if userDefaults.synchronize() {
                print("UserDefaults Sync succesful.")
                return true
            } else {
                print("UserDefaults Sync failure.")
                return false
            }
        }
        return false
    }
}