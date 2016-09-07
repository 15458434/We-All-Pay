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
        let userDefaults = UserDefaults.standard
        fromiAd = userDefaults.bool(forKey: fromiAdKey)
        
        super.init()
    }
    
    init(completionHandler: () -> ()) {
        let userDefaults = UserDefaults.standard
        let fromiAdValueFromUserDefaults: Bool! = userDefaults.bool(forKey: fromiAdKey)
        if let myValue = fromiAdValueFromUserDefaults {
            fromiAd = NSNumber(value: myValue)
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
    
    func fetchAttribution(_ completionHandler: () -> ()){
        ADClient.shared().lookupAdConversionDetails({ (appPurchaseDate, iAdImpressionDate) -> Void in
            // True if we were installed from an iAd campaign
            if iAdImpressionDate != nil {
                self.fromiAd = true
            } else {
                self.fromiAd = false
            }
            completionHandler()
            _ = self.save()
        })
    }
    
    func save() -> Bool {
        let userDefaults = UserDefaults.standard
        if let fromiAdValue = fromiAd?.boolValue {
            userDefaults.set(fromiAdValue, forKey: fromiAdKey)
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
