//
//  MCStoreInterface.swift
//  We all pay
//
//  Created by Mark Cornelisse on 22/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation
import StoreKit
import Security

let kApplyProVersionNotification = "Apply pro version"

class MCStoreInterface: NSObject, SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate, UIAlertViewDelegate {
    private var productRequest: SKProductsRequest?
    private var lastSKProductsRequestError: NSError?
    private var appStoreUnreachableAlert: UIAlertView?
    
    private var applyProVersionSuccesful: Bool = false
    
    var proProduct: SKProduct!
    
    var productIdentifiers: [String] {
        let url = NSBundle.mainBundle().URLForResource("Product ids", withExtension: "plist")!
        return NSArray(contentsOfURL: url) as! [String]
    }
    
    var isProProductPurchased: Bool {
        let productIdentifier: String = self.productIdentifiers.first! as String
        return NSUserDefaults.standardUserDefaults().valueForKey(productIdentifier) as! Bool? ?? false
    }
    
    static var defaultStoreInterface: MCStoreInterface = MCStoreInterface()
    
    class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    class func applyProVersionNotification() -> String {
        return kApplyProVersionNotification;
    }
    
    // MARK: Private in this class
    
    func applyProVersion() {
//        let productIdentifier = self.productIdentifiers.first
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "com.Greenhair.We_all_pay.pro")
        applyProVersionSuccesful = NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func completeTransaction(transaction: SKPaymentTransaction) {
        if transaction.payment.productIdentifier == "com.Greenhair.We_all_pay.pro" {
            print("\(transaction.payment.productIdentifier) was bought")
            self.applyProVersion()
            NSNotificationCenter.defaultCenter().postNotificationName(kApplyProVersionNotification, object: self, userInfo: ["Kind of purchase": "new buy"])
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        }
    }
    
    func failedTransaction(transaction: SKPaymentTransaction) {
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        print("The sale went bad: \(transaction.error!.localizedDescription)")
    }
    
    func restoreTransaction(transaction: SKPaymentTransaction) {
        if transaction.originalTransaction?.payment.productIdentifier == "com.Greenhair.We_all_pay.pro" {
            self.applyProVersion()
            NSNotificationCenter.defaultCenter().postNotificationName(kApplyProVersionNotification, object: self, userInfo: ["Kind of purchase" : "restore purchase"])
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        }
    }
    
    // MARK: Initialisers
    
    private override init() {
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    // MARK: Public in this class
    
    func validateProductIdentifiers() {
        print("Validating product identifiers.")
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers) as Set<String>)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func buyProProductSendFrom(viewController: UIViewController) {
        if proProduct != nil {
            let payment = SKMutablePayment(product: proProduct)
            payment.quantity = 1
            SKPaymentQueue.defaultQueue().addPayment(payment)
        } else {
            let title = NSLocalizedString("App Store unavailable", comment: "Message that pops up when the App Store is not available.")
            let message = NSLocalizedString("Unable to connect to the App Store. Please connect to the internet.", comment: "Message body explaining the App Store can't be reached.")
            let dismissButtonTitle = NSLocalizedString("Dismiss", comment: "Button that says dismiss.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: dismissButtonTitle, style: .Default, handler: { (action) -> Void in
                print("App Store unavailable dismissed.")
            })
            alertController.addAction(dismissAction)
            viewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func restorePreviousPurchases() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func reset() {
        let productIdentifier: String = self.productIdentifiers.first! as String
        NSUserDefaults.standardUserDefaults().removeObjectForKey(productIdentifier)
    }
    
    // MARK: UI Alert View Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView == appStoreUnreachableAlert {
            appStoreUnreachableAlert = nil
        }
    }
    
    // MARK: SK Request Delegate
    func requestDidFinish(request: SKRequest) {
        print("SKRequest: \(request) did finish.")
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print("SKRequest: \(request) did fail with error: \(error)")
        if error.domain == SKErrorDomain {
            switch error.code {
            case 0:
                print("App store not available.")
                self.lastSKProductsRequestError = error
            default:
                print("App store something is wrong.")
                self.lastSKProductsRequestError = error
            }
        }
    }
    
    // MARK: SK Products Request Delegate
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("Products Delivered")
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid product: \(invalidIdentifier)")
        }
        proProduct = response.products.first
        lastSKProductsRequestError = nil
        NSNotificationCenter.defaultCenter().postNotificationName("Product price", object: self, userInfo: [proProduct.productIdentifier: proProduct.price])
    }
    
    // MARK: SK Payment Transaction Observer
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("UpdatedTransactions: \(transactions)")
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                self.completeTransaction(transaction as SKPaymentTransaction)
            case SKPaymentTransactionState.Failed:
                self.failedTransaction(transaction as SKPaymentTransaction)
            case SKPaymentTransactionState.Restored:
                self.restoreTransaction(transaction as SKPaymentTransaction)
            default:
                print("Transaction state: \(transaction.transactionState)")
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("RemovedTransactions: \(transactions)")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        if queue.transactions.count == 0 {
            print("No previous purchases were restored.")
            NSNotificationCenter.defaultCenter().postNotificationName("Restore previous purchases", object: self, userInfo: ["status": "Not restored"])
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        print("UpdatedDownload: \(downloads)")
    }
}

extension SKProduct {
    var priceString: String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.formatterBehavior = .BehaviorDefault
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = self.priceLocale
        return numberFormatter.stringFromNumber(self.price)!
    }
}
