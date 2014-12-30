//
//  TodayViewController.swift
//  Who is paying next
//
//  Created by Mark Cornelisse on 28/11/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var theLabel: UILabel!
    
    var tonightsBillID: String!
    var tripName: String!
    var nextPayerID: String!
    var fullNameNextPayer: String!
    var dateSaved: NSDate!
    var valid: Bool!
    
    func updateLocalOptionalsFromUserDefaults() -> Bool {
        #if DEBUG
            println("\(self): updateLocalOptionalsFromUserDefaults")
        #endif
        let userDefaultsInterface: MCWhoPayingUserDefaultsStoreInterface = MCWhoPayingUserDefaultsStoreInterface()
        
        if userDefaultsInterface.valid {
            tonightsBillID = userDefaultsInterface.tonightsBillUUID
            tripName = userDefaultsInterface.tripName
            nextPayerID = userDefaultsInterface.nextPayerUUID
            fullNameNextPayer = userDefaultsInterface.fullNameOfNextPayer
            dateSaved = userDefaultsInterface.dateSaved
            valid = userDefaultsInterface.valid
            
            return true
        } else {
            return false
        }
    }
    
    func updateLabel() {
        println("updateLabel")
        if let validValue = valid {
            if validValue == true {
                let finalString: String = "For your event \(tripName), \(fullNameNextPayer) should pay next."
                println(finalString)
                if countElements(finalString) > 0 {
                    theLabel.attributedText = betterCreateAttributesStringForWhoIsPayingNext(tripName, fullNameNextPayer)
                } else {
                    theLabel.attributedText = createErrorMessage()
                    NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: MCWhoIsPayingNextBundleIdentifier)
                }
            } else {
                theLabel.attributedText = createErrorMessage()
                NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: MCWhoIsPayingNextBundleIdentifier)
            }
        } else {
            theLabel.attributedText = createErrorMessage()
            NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: MCWhoIsPayingNextBundleIdentifier)
        }
    }
    
    func defaultsDidUpdate(notification: NSNotification) {
        if updateLocalOptionalsFromUserDefaults() {
            updateLabel()
            NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: MCWhoIsPayingNextBundleIdentifier)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsDidUpdate:", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        #if DEBUG
            println("\(self): widgetPerformUpdateWithCompletionHandler")
        #endif
        if updateLocalOptionalsFromUserDefaults() {
            updateLabel()
            completionHandler(NCUpdateResult.NewData)
        } else {
            updateLabel()
            completionHandler(NCUpdateResult.NewData)
        }
    }
}
