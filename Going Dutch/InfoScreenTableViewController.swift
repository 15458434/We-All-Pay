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

import RateMeControllerForiOS
import FirebaseAnalytics

private let productName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
private let shortVersionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
private let versionString = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

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
    @IBAction func mainCancelButtonPressed(_ sender: AnyObject) {
        self.navigationController?.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    // MARK: New in this class
    
    private func showAllMyApps() {
        let url = URL(string: "itms-apps://search.itunes.apple.com/WebObjects/MZContentLink.woa/wa/link?mt=8&path=apps%2fmarkcornelisse")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                guard success else {
                    debugPrint("Unable to open url")
                    return
                }
            }
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    private func openMailComposer() {
        if MailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients(["support@markcornelisse.nl"])
            let subjectString = "Feedback on \(productName) \(shortVersionString)"
            mailComposer.setSubject(subjectString)
            mailComposer.mailComposeDelegate = self
            present(mailComposer, animated: true) { () -> Void in
                // Nothing to do.
            }
        } else {
            let title = NSLocalizedString("Unable to send email", comment: "Unable to send email")
            let message = NSLocalizedString("Please configure your mail in Settings", comment: "Please configure your mail in Settings")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelButtonText = NSLocalizedString("Dismiss", comment: "Dismiss")
            let cancelAction = UIAlertAction(title: cancelButtonText, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Notifications
    @objc func applyProVersion(_ notification: Notification) {
        Analytics.logEvent("Applying Pro version", parameters: nil)
        OperationQueue.main.addOperation { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: UITableView.RowAnimation.automatic)
            self.tableView.endUpdates()
            
            var title: String!
            var message: String?
            if (notification as NSNotification).userInfo!["Kind of purchase"] as? String == "new buy" {
                title = NSLocalizedString("Thank you for purchasing", comment: "Thank you for purchasing")
                message = NSLocalizedString("\(productName) is now free of any ads.", comment: "\(productName) is now free of any ads.")

            } else if (notification as NSNotification).userInfo!["Kind of purchase"] as? String == "restore purchase" {
                title = NSLocalizedString("Ad free version restored.", comment: "Ad free version restored.")
            }
            let dismissText = NSLocalizedString("Dismiss", comment: "Dismiss")
            var alertController: UIAlertController!
            alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: dismissText, style: .cancel, handler:nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func postProductPrice(_ notification: Notification) {
        if !MCStoreInterface.defaultStoreInterface.isProProductPurchased {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! MCTwoLabelIscreenTableViewCell
            cell.rightLabel.text = MCStoreInterface.defaultStoreInterface.proProduct.priceString
        }
    }
    
    @objc func restorePreviousPurchasesFailed(_ notification: Notification) {
        Analytics.logEvent("Restore Previous Purchases", parameters: nil)
        if (notification as NSNotification).userInfo!["status"] as? String == "Not restored" {
            let myPresenter = presentingViewController!
            let title = NSLocalizedString("Nothing to restore", comment: "Nothing to restore")
            let dismiss = NSLocalizedString("Dismiss", comment: "Dismiss")
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: dismiss, style: .cancel, handler:nil)
            alertController.addAction(cancelAction)
            myPresenter.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Inherited from super
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.text = "\(shortVersionString) build \(versionString)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(InfoScreenTableViewController.applyProVersion(_:)), name: NSNotification.Name(rawValue: MCStoreInterface.applyProVersionNotification()), object: MCStoreInterface.defaultStoreInterface)
        NotificationCenter.default.addObserver(self, selector: #selector(InfoScreenTableViewController.postProductPrice(_:)), name: NSNotification.Name(rawValue: "Product price"), object: MCStoreInterface.defaultStoreInterface)
        NotificationCenter.default.addObserver(self, selector: #selector(InfoScreenTableViewController.restorePreviousPurchasesFailed(_:)), name: NSNotification.Name(rawValue:"Restore previous purchases"), object: MCStoreInterface.defaultStoreInterface)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: MF MAil Compose Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result) {
        case MFMailComposeResult.cancelled:
            Analytics.logEvent("Feedback email cancelled", parameters: nil)
            dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved:
            Analytics.logEvent("Feedback email saved", parameters: nil)
            dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent:
            Analytics.logEvent("Feedback email send", parameters: nil)
            dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed:
            if let error = error {
                Analytics.logEvent("Feedback email failed", parameters: ["error": error as NSError])
            } else {
                Analytics.logEvent("Feedback email failed", parameters: nil)
            }
            print("Failed to open mailComposeController")
        }
    }
    
    // MARK: UI Table View Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0, 0):
            Analytics.logEvent("Buy Pro Product Pressed", parameters: nil)
            MCStoreInterface.defaultStoreInterface.buyProProductSendFrom(self)
        case (0, 1):
            Analytics.logEvent("Restore Previous Purchases pressed", parameters: nil)
            MCStoreInterface.defaultStoreInterface.restorePreviousPurchases()
        case (1, 0):
            Analytics.logEvent("Rate Me pressed", parameters: nil)
            RateMeController.openReviewLink()
        case (1, 1):
            Analytics.logEvent("My Apps pressed", parameters: nil)
            showAllMyApps()
        case (2, 0):
            Analytics.logEvent("Send Feedback pressed", parameters: nil)
            openMailComposer()
        default:
            print("Nothing to open")
        }
        let thisCell = tableView.cellForRow(at: indexPath)
        thisCell!.setSelected(false, animated: true)
    }
    
    // MARK: UI Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MCTwoLabelIscreenTableViewCell", for: indexPath) as! MCTwoLabelIscreenTableViewCell
            cell.leftLabel.text = NSLocalizedString("Buy ad free version", comment: "Buy ad free Version")
            cell.rightLabel.isHidden = false
            if MCStoreInterface.defaultStoreInterface.proProduct != nil {
                cell.rightLabel.text = MCStoreInterface.defaultStoreInterface.proProduct.priceString
            } else {
                cell.rightLabel.text = ""
            }
            return cell
        case (0, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MCTwoLabelIscreenTableViewCell", for: indexPath) as! MCTwoLabelIscreenTableViewCell
            cell.leftLabel.text = NSLocalizedString("Restore previous purchases", comment: "Restore previous purchases")
            cell.rightLabel.isHidden = true
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MCTwoLabelIscreenTableViewCell", for: indexPath) as! MCTwoLabelIscreenTableViewCell
            cell.leftLabel.text = NSLocalizedString("Rate me", comment: "Text of the Rate me button")
            cell.rightLabel.isHidden = true
            return cell
        case (1, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MCTwoLabelIscreenTableViewCell", for: indexPath) as! MCTwoLabelIscreenTableViewCell
            cell.leftLabel.text = NSLocalizedString("My Apps", comment: "Text of the the button that takes you to my apps in the AppStore")
            cell.rightLabel.isHidden = true
            return cell
        case (2, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MCTwoLabelIscreenTableViewCell", for: indexPath) as! MCTwoLabelIscreenTableViewCell
            cell.leftLabel.text = NSLocalizedString("Give feedback", comment: "Give feedback")
            cell.rightLabel.isHidden = true
            return cell
        default:
            assert(false, "This section: \((indexPath as NSIndexPath).section) and row: \((indexPath as NSIndexPath).row) are not valid")
            return UITableViewCell()
        }
    }
}
