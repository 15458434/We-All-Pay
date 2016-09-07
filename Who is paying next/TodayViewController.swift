//
//  TodayViewController.swift
//  Who is paying next
//
//  Created by Mark Cornelisse on 28/11/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

import UIKit
import NotificationCenter
import WhoPayingUserDefaultsStoreInterface

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var theLabel: UILabel!
    
    var tonightsBillID: String!
    var tripName: String!
    var nextPayerID: String!
    var fullNameNextPayer: String!
    var dateSaved: Date!
    var valid: Bool!
    
    func updateLocalOptionalsFromUserDefaults() -> Bool {
        debugPrint("\(self): updateLocalOptionalsFromUserDefaults")
    
        let userDefaultsInterface = WhoPayingUserDefaultsStoreInterface()
        
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
        print("updateLabel", terminator: "")
        if let validValue = valid {
            if validValue == true {
                let finalString: String = "For your event \(tripName), \(fullNameNextPayer) should pay next."
                print(finalString, terminator: "")
                if finalString.characters.count > 0 {
                    theLabel.attributedText = betterCreateAttributesStringForWhoIsPayingNext(tripName, fullNameNextPayer: fullNameNextPayer)
                    theLabel.setNeedsUpdateConstraints()
                    NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: WhoPayingUserDefaultsStoreInterface.MCWhoIsPayingNextBundleIdentifier)
                } else {
                    theLabel.attributedText = createErrorMessage()
                    theLabel.setNeedsUpdateConstraints()
                    NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: WhoPayingUserDefaultsStoreInterface.MCWhoIsPayingNextBundleIdentifier)
                }
            } else {
                theLabel.attributedText = createErrorMessage()
                theLabel.setNeedsUpdateConstraints()
                NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: WhoPayingUserDefaultsStoreInterface.MCWhoIsPayingNextBundleIdentifier)
            }
        } else {
            theLabel.attributedText = createErrorMessage()
            theLabel.setNeedsUpdateConstraints()
            NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: WhoPayingUserDefaultsStoreInterface.MCWhoIsPayingNextBundleIdentifier)
        }
    }
    
    func defaultsDidUpdate(_ notification: Notification) {
        if updateLocalOptionalsFromUserDefaults() {
            updateLabel()
        }
        NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: WhoPayingUserDefaultsStoreInterface.MCWhoIsPayingNextBundleIdentifier)
    }
    
    func tappedInTheBackground(_ sender: AnyObject) {
        debugPrint("I am tapped.")
        var urlString = "weallpay:///"
        if let validValue = valid {
            if validValue == true {
                urlString = "weallpay:///\(tonightsBillID)/\(nextPayerID)"
            }
        }
        print("Open: \(urlString)", terminator: "")
        let url = URL(string: urlString)
        self.extensionContext?.open(url!, completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.defaultsDidUpdate(_:)), name: UserDefaults.didChangeNotification, object: nil)

        // Setup a tap in the Today Extension to open We all pay.
        let thatTickles = UITapGestureRecognizer(target: self, action: #selector(TodayViewController.tappedInTheBackground(_:)))
        thatTickles.cancelsTouchesInView = false
        self.view.addGestureRecognizer(thatTickles)
        self.view.preservesSuperviewLayoutMargins = true
    }
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        debugPrint("\(self): widgetPerformUpdateWithCompletionHandler")
        if updateLocalOptionalsFromUserDefaults() {
            updateLabel()
            completionHandler(NCUpdateResult.newData)
        } else {
            updateLabel()
            completionHandler(NCUpdateResult.newData)
        }
    }
}
