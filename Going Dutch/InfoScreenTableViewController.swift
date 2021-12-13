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

final class InfoScreenTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    @objc var notificationEnvironmentModel: NotificationsInfoModel!
    @IBOutlet var model: InfoModel!
    
    @IBOutlet var versionLabel: UILabel!
    
    private var numberOfRowsInSection0: Int {
        if (MCStoreInterface.canMakePayments() && !(MCStoreInterface.defaultStoreInterface.isProProductPurchased)) {
            return 2
        } else {
            return 0
        }
    }
    
    @IBAction func mainCancelButtonPressed(_ sender: AnyObject) {
        self.navigationController?.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    private func showAllMyApps() {
        let url = URL(string: "itms-apps://search.itunes.apple.com/WebObjects/MZContentLink.woa/wa/link?mt=8&path=apps%2fmarkcornelisse")!
        UIApplication.shared.open(url, options: [:]) { (success) in
            guard success else {
                debugPrint("Unable to open url")
                return
            }
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
            let title = NSLocalizedString("info_view_alert_title_cannot_send_email", value: "Unable to send email", comment: "Title of an alert to tell the user he's unable to send email.")
            let message = NSLocalizedString("info_view_alert_message_cannot_send_email", value: "Please configure your mail in Settings", comment: "Message of the cannot send email alert title with an action for the user to take.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelButtonText = model.dismissButtonTitle
            let cancelAction = UIAlertAction(title: cancelButtonText, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func applyProVersion(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: UITableView.RowAnimation.automatic)
            self.tableView.endUpdates()
            
            var title: String!
            var message: String?
            let kindOfPurchaseString = notification.userInfo!["Kind of purchase"] as? String
            switch kindOfPurchaseString {
            case "new buy":
                title = NSLocalizedString("info_view_alert_purchased_title", value: "Thank you for purchasing", comment: "Title of an alert to the user that thanks them for making the ad free in app purchase.")
                message = NSLocalizedString("info_view_alert_purchased_message", value: "\(productName) is now free of any ads.", comment: "Messages of an alert to the user that thanks them for making the ad free in app purchase")
            case "restore purchase":
                title = NSLocalizedString("info_view_alert_restore_purchase_title", value: "Ad free version restored", comment: "title of an alert to the user that says their ad free version is restored")
                message = NSLocalizedString("info_view_alert_restore_purchase_message", value: "Welcome back. Your ad free experience has been restored for you", comment: "message of an alert to the user that says their ad free version is restored")
            default:
                fatalError("Purchase info invalid")
            }
            let dismissText = self.model.dismissButtonTitle
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
            cell.rightLabel.text = MCStoreInterface.defaultStoreInterface.proProduct?.localizedPriceString
        }
    }
    
    @objc func restorePreviousPurchasesFailed(_ notification: Notification) {
        if notification.userInfo!["status"] as? String == "Not restored" {
            let myPresenter = presentingViewController!
            let title = NSLocalizedString("info_view_alert_failed_to_restore", value: "Nothing to restore", comment: "Title of an alert that is shown when the restoration of in app purchases failed to restore")
            let dismiss = model.dismissButtonTitle
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: dismiss, style: .cancel, handler:nil)
            alertController.addAction(cancelAction)
            myPresenter.present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result) {
        case MFMailComposeResult.cancelled:
            dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved:
            dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent:
            dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed:
            // TODO: Add failure handling
            print("Failed to open mailComposeController")
        @unknown default:
            fatalError("Unknown value for MFMailComposeResult")
        }
    }
    // MARK: UITableViewController
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = cell as! MCPurchaseTableViewCell
            cell.priceLabel!.isHidden = false
            cell.update(MCStoreInterface.defaultStoreInterface)
        case (0, 1):
            let cell = cell as! MCTwoLabelIscreenTableViewCell
            cell.leftLabel.text = NSLocalizedString("info_view_cell_restore_purchases", value: "Restore previous purchases", comment: "Text of a button in the info view that initiates restoring the in app purchases")
            cell.rightLabel.isHidden = true
        case (1, 0):
            let cell = cell as! NotificationsCountTableViewCell
            cell.update(model: notificationEnvironmentModel)
        default:
            ()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            MCStoreInterface.defaultStoreInterface.buyProProductSendFrom(self)
        case (0, 1):
            MCStoreInterface.defaultStoreInterface.restorePreviousPurchases()
        case (1, 0):
            let cellPressed = tableView.cellForRow(at: indexPath)
            performSegue(withIdentifier: "OpenNotifications", sender: cellPressed)
        case (2, 0):
            RateMeController.openReviewLink()
        case (2, 1):
            showAllMyApps()
        case (3, 0):
            openMailComposer()
        default:
            print("Nothing to open")
        }
        let thisCell = tableView.cellForRow(at: indexPath)
        thisCell!.setSelected(false, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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
            return 1
        case 2:
            return 2
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MCPurchaseTableViewCell", for: indexPath) as! MCPurchaseTableViewCell
            return cell
        case (0, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MCTwoLabelIscreenTableViewCell", for: indexPath) as! MCTwoLabelIscreenTableViewCell
            return cell
        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCountTableViewCell", for: indexPath) as! NotificationsCountTableViewCell
            return cell
        case (2, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MCTwoLabelIscreenTableViewCell", for: indexPath) as! MCTwoLabelIscreenTableViewCell
            cell.leftLabel.text = NSLocalizedString("info_view_cell_rate_me", value: "Rate me", comment: "Text of a button in the info view that opens the rate me dialogue")
            cell.rightLabel.isHidden = true
            return cell
        case (2, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MCTwoLabelIscreenTableViewCell", for: indexPath) as! MCTwoLabelIscreenTableViewCell
            cell.leftLabel.text = NSLocalizedString("info_view_cell_my_apps", value: "My Apps", comment: "Text of a button in the info view that opens the page in the App Store with all of my apps.")
            cell.rightLabel.isHidden = true
            return cell
        case (3, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MCTwoLabelIscreenTableViewCell", for: indexPath) as! MCTwoLabelIscreenTableViewCell
            cell.leftLabel.text = NSLocalizedString("info_view_cell_feedback", value: "Give feedback", comment: "Text of a button in the info view that opens up a mail dialogue to send feedback to support")
            cell.rightLabel.isHidden = true
            return cell
        default:
            fatalError("This section: \(indexPath.section) and row: \(indexPath.row) are not valid")
        }
    }
    
    // MARK: UIViewController
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "OpenNotifications":
            let destination = segue.destination as! NotificationsTableViewController
            destination.preferredContentSize = CGSize(width: 320, height: 0)
        default:
            fatalError("Unknown segue with identifier: \(segue.identifier!)")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
