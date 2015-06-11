//: Playground - noun: a place where people can play

import Foundation

private let kShowHints = "kShowHints"

@objc class HintsController: NSObject {
    var showHints: Bool! {
        set(newValue) {
            self.showHints = newValue
            // Opposite value is stored in NSUserDefaults
            NSUserDefaults.standardUserDefaults().setBool(!newValue, forKey: kShowHints)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return self.showHints
        }
    }
    
    override init() {
        super.init()
        // Opposite value is stored in NSUserDefaults
        self.showHints = !NSUserDefaults.standardUserDefaults().boolForKey(kShowHints)
    }
}

let controller = HintsController()
controller.showHints = false
