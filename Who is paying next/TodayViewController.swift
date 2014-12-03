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
    
    func updateLocalOptionalsFromUserDefaults() -> Bool {
        #if DEBUG
            println("\(self): updateLocalOptionalsFromUserDefaults")
        #endif
        let userDefaultsInterface: MCWhoPayingUserDefaultsStoreInterface = MCWhoPayingUserDefaultsStoreInterface()
        if userDefaultsInterface.areAllValuesValid() {
            tonightsBillID = userDefaultsInterface.tonightsBillUUID
            tripName = userDefaultsInterface.tripName
            nextPayerID = userDefaultsInterface.nextPayerUUID
            fullNameNextPayer = userDefaultsInterface.fullNameOfNextPayer
            
            return true
        } else {
            return false
        }
    }
    
    func updateLabel() {
        println("updateLabel")
        if let theTripName = tripName {
            if let thePayerName = fullNameNextPayer {
                let finalString: String = "For your event \(theTripName), \(fullNameNextPayer) should pay next."
                println(finalString)
                theLabel.attributedText = createAttributesStringForWhoIsPayingNext(theTripName, thePayerName)
            } else {
                NCWidgetController.widgetController().setHasContent(false, forWidgetWithBundleIdentifier: MCWhoIsPayingNextBundleIdentifier)                
            }
        } else {
            NCWidgetController.widgetController().setHasContent(false, forWidgetWithBundleIdentifier: MCWhoIsPayingNextBundleIdentifier)
        }
    }
    
    func defaultsDidUpdate(notification: NSNotification) {
        if updateLocalOptionalsFromUserDefaults() {
            updateLabel()
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
            NCWidgetController.widgetController().setHasContent(false, forWidgetWithBundleIdentifier: MCWhoIsPayingNextBundleIdentifier);
            completionHandler(NCUpdateResult.Failed)
        }
    }
}
