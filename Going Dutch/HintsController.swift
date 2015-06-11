//
//  HintsController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

private let kShowHints = "kShowHints"

@objc class HintsController: NSObject {
    @objc var showHints: Bool = true {
        willSet(newValue) {
            self.showHints = newValue
            // Opposite value is stored in NSUserDefaults
            NSUserDefaults.standardUserDefaults().setBool(!newValue, forKey: kShowHints)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    override init() {
        super.init()
        // Opposite value is stored in NSUserDefaults
        self.showHints = !NSUserDefaults.standardUserDefaults().boolForKey(kShowHints)
    }
}
