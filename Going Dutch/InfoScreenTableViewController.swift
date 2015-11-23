//
//  InfoScreenTableViewController.swift
//  Bift
//
//  Created by Mark Cornelisse on 18/08/15.
//  Copyright (c) 2015 Over de muur producties. All rights reserved.
//

import UIKit
import MessageUI
import Social
import StoreKit

private let productName = NSBundle.mainBundle().infoDictionary!["CFBundleDisplayName"] as! String
private let shortVersionString = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
private let versionString = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String

class InfoScreenTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    // MARK: Properties
    private var numberOfRowsInSection0: Int {
        if (MCStoreInterface.canMakePayments() && !(MCStoreInterface.defaultStoreInterface.isProProductPurchased)) {
            return 2
        } else {
            return 0
        }
    }
    
    // MARK: IB Outlet
    @IBOutlet var versionLabel: UILabel!
    
    // MARK: IB Actions
    @IBAction func mainCancelButtonPressed(sender: AnyObject) {
        self.navigationController?.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tweetAboutUsPressed(sender: AnyObject) {
        let twitterComposer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        twitterComposer.setInitialText("Thank you @MarkCornelisse, I have no more money problems with my friends thanks to your \(productName). #ios #app")
        twitterComposer.addURL(NSURL(string: "https://itunes.apple.com/us/app/we-all-pay/id642135963?ls=1&mt=8"))
        presentViewController(twitterComposer, animated: true, completion: nil)
    }
    
    // MARK: New in this class
    
    private func openMyAppStoreLink() {
        let url = NSURL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=642135963&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    private func showAllMyApps() {
        let url = NSURL(string: "itms-apps://search.itunes.apple.com/WebObjects/MZContentLink.woa/wa/link?mt=8&path=apps%2fmarkcornelisse")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    private func openMailComposer() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients(["support@markcornelisse.nl"])
            let subjectString = "Feedback on \(productName) \(shortVersionString)"
            mailComposer.setSubject(subjectString)
            mailComposer.mailComposeDelegate = self
            presentViewController(mailComposer, animated: true) { () -> Void in
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
                mailComposer.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            let title = NSLocalizedString("Unable to send email", comment: "Unable to send email")
            let message = NSLocalizedString("Please configure your mail in Settings", comment: "Please configure your mail in Settings")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let cancelButtonText = NSLocalizedString("Dismiss", comment: "Dismiss")
            let cancelAction = UIAlertAction(title: cancelButtonText, style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Notifications
    func applyProVersion(notification: NSNotification) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            var title: String!
            var message: String?
            if notification.userInfo!["Kind of purchase"] as? String == "new buy" {
                title = NSLocalizedString("Thank you for purchasing", comment: "Thank you for purchasing")
                message = NSLocalizedString("\(productName) is now free of any ads.", comment: "\(productName) is now free of any ads.")

            } else if notification.userInfo!["Kind of purchase"] as? String == "restore purchase" {
                title = NSLocalizedString("Ad free version restored.", comment: "Ad free version restored.")
            }
            let dismissText = NSLocalizedString("Dismiss", comment: "Dismiss")
            var alertController: UIAlertController!
            alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: dismissText, style: .Cancel, handler:nil)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func postProductPrice(notification: NSNotification) {
        if !MCStoreInterface.defaultStoreInterface.isProProductPurchased {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! MCTwoLabelIscreenTableViewCell
            cell.rightLabel.text = MCStoreInterface.defaultStoreInterface.proProduct.priceString
        }
    }
    
    func restorePreviousPurchasesFailed(notification: NSNotification) {
        if notification.userInfo!["status"] as? String == "Not restored" {
            let myPresenter = presentingViewController!
            let title = NSLocalizedString("Nothing to restore", comment: "Nothing to restore")
            let dismiss = NSLocalizedString("Dismiss", comment: "Dismiss")
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: dismiss, style: .Cancel, handler:nil)
            alertController.addAction(cancelAction)
            myPresenter.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Inherited from super
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.text = "\(shortVersionString) build \(versionString)"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applyProVersion:", name: MCStoreInterface.applyProVersionNotification(), object: MCStoreInterface.defaultStoreInterface)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "postProductPrice:", name: "Product price", object: MCStoreInterface.defaultStoreInterface)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "restorePreviousPurchasesFailed:", name: "Restore previous purchases", object: MCStoreInterface.defaultStoreInterface)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: MF MAil Compose Delegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch (result.rawValue) {
        case MFMailComposeResultCancelled.rawValue:
            dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultSaved.rawValue:
            dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultSent.rawValue:
            dismissViewControllerAnimated(true, completion: nil)
        default:
            print("Failed to open mailComposeController")
            // TODO: Add message to the user.
        }
    }
    
    // MARK: UI Table View Delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            MCStoreInterface.defaultStoreInterface.buyProProductSendFrom(self)
        case (0, 1):
            MCStoreInterface.defaultStoreInterface.restorePreviousPurchases()
        case (1, 0):
            openMyAppStoreLink()
        case (1, 1):
            showAllMyApps()
        case (2, 0):
            openMailComposer()
        default:
            print("Nothing to open")
        }
        let thisCell = tableView.cellForRowAtIndexPath(indexPath)
        thisCell!.setSelected(false, animated: true)
    }
    
    // MARK: UI Table View Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            if (MCStoreInterface.canMakePayments()) && !MCStoreInterface.defaultStoreInterface.isProProductPurchased {
                return numberOfRowsInSection0
            } else {
                return 0
            }
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MCTwoLabelIscreenTableViewCell", forIndexPath: indexPath) as! MCTwoLabelIscreenTableViewCell
            cell.leftLabel.text = NSLocalizedString("Buy ad free version", comment: "Buy ad free Version")
            if MCStoreInterface.defaultStoreInterface.proProduct != nil {
                cell.rightLabel.text = MCStoreInterface.defaultStoreInterface.proProduct.priceString
            } else {
                cell.rightLabel.text = ""
            }
            return cell
        case (0, 1):
            let cell = tableView.dequeueReusableCellWithIdentifier("MCOneLabelIScreenTableViewCell", forIndexPath: indexPath) as! MCOneLabelIScreenTableViewCell
            cell.oneTextLabel.text = NSLocalizedString("Restore previous purchases", comment: "Restore previous purchases")
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MCOneLabelIScreenTableViewCell", forIndexPath: indexPath) as! MCOneLabelIScreenTableViewCell
            cell.oneTextLabel.text = NSLocalizedString("Rate me", comment: "Text of the Rate me button")
            return cell
        case (1, 1):
            let cell = tableView.dequeueReusableCellWithIdentifier("MCOneLabelIScreenTableViewCell", forIndexPath: indexPath) as! MCOneLabelIScreenTableViewCell
            cell.oneTextLabel.text = NSLocalizedString("My Apps", comment: "Text of the the button that takes you to my apps in the App Store")
            return cell
        case (2, 0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MCOneLabelIScreenTableViewCell", forIndexPath: indexPath) as! MCOneLabelIScreenTableViewCell
            cell.oneTextLabel.text = NSLocalizedString("Give feedback", comment: "Give feedback")
            return cell
        default:
            assert(false, "This section: \(indexPath.section) and row: \(indexPath.row) are not valid")
            return UITableViewCell()
        }
    }
}