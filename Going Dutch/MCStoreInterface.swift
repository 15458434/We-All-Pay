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

@objc class MCStoreInterface: NSObject, SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate, UIAlertViewDelegate {
    private var productRequest: SKProductsRequest?
    private var lastSKProductsRequestError: NSError?
    
    private var applyProVersionSuccesful: Bool = false
    
    var proProduct: SKProduct!
    
    var productIdentifiers: [String] {
        let url = Bundle.main.url(forResource: "Product ids", withExtension: "plist")!
        return NSArray(contentsOf: url) as! [String]
    }
    
    @objc var isProProductPurchased: Bool {
        let productIdentifier: String = self.productIdentifiers.first! as String
        return UserDefaults.standard.value(forKey: productIdentifier) as! Bool? ?? false
    }
    
    @objc static var defaultStoreInterface: MCStoreInterface = MCStoreInterface()
    
    class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    @objc class func applyProVersionNotification() -> String {
        return kApplyProVersionNotification;
    }
    
    // MARK: Private in this class
    
    func applyProVersion() {
//        let productIdentifier = self.productIdentifiers.first
        UserDefaults.standard.set(true, forKey: "com.Greenhair.We_all_pay.pro")
        applyProVersionSuccesful = UserDefaults.standard.synchronize()
    }
    
    func completeTransaction(_ transaction: SKPaymentTransaction) {
        if transaction.payment.productIdentifier == "com.Greenhair.We_all_pay.pro" {
            print("\(transaction.payment.productIdentifier) was bought")
            self.applyProVersion()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kApplyProVersionNotification), object: self, userInfo: ["Kind of purchase": "new buy"])
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        print("The sale went bad: \(transaction.error!.localizedDescription)")
    }
    
    func restoreTransaction(_ transaction: SKPaymentTransaction) {
        if transaction.original?.payment.productIdentifier == "com.Greenhair.We_all_pay.pro" {
            self.applyProVersion()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kApplyProVersionNotification), object: self, userInfo: ["Kind of purchase" : "restore purchase"])
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    // MARK: Initialisers
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: Public in this class
    
    @objc func validateProductIdentifiers() {
        print("Validating product identifiers.")
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers) as Set<String>)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func buyProProductSendFrom(_ viewController: UIViewController) {
        if proProduct != nil {
            let payment = SKMutablePayment(product: proProduct)
            payment.quantity = 1
            SKPaymentQueue.default().add(payment)
        } else {
            let title = NSLocalizedString("App Store unavailable", comment: "Message that pops up when the App Store is not available.")
            let message = NSLocalizedString("Unable to connect to the App Store. Please connect to the internet.", comment: "Message body explaining the App Store can't be reached.")
            let dismissButtonTitle = NSLocalizedString("Dismiss", comment: "Button that says dismiss.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: dismissButtonTitle, style: .default, handler: { (action) -> Void in
                print("App Store unavailable dismissed.")
            })
            alertController.addAction(dismissAction)
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func restorePreviousPurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func reset() {
        let productIdentifier: String = self.productIdentifiers.first! as String
        UserDefaults.standard.removeObject(forKey: productIdentifier)
    }
    
    // MARK: SK Request Delegate
    func requestDidFinish(_ request: SKRequest) {
        print("SKRequest: \(request) did finish.")
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("SKRequest: \(request) did fail with error: \(error)")
        if error._domain == SKErrorDomain {
            switch error._code {
            case 0:
                print("App store not available.")
                self.lastSKProductsRequestError = error as NSError?
            default:
                print("App store something is wrong.")
                self.lastSKProductsRequestError = error as NSError?
            }
        }
    }
    
    // MARK: SK Products Request Delegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Products Delivered")
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid product: \(invalidIdentifier)")
        }
        proProduct = response.products.first
        lastSKProductsRequestError = nil
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Product price"), object: self, userInfo: [proProduct.productIdentifier: proProduct.price])
    }
    
    // MARK: SK Payment Transaction Observer
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("UpdatedTransactions: \(transactions)")
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                self.completeTransaction(transaction as SKPaymentTransaction)
            case SKPaymentTransactionState.failed:
                self.failedTransaction(transaction as SKPaymentTransaction)
            case SKPaymentTransactionState.restored:
                self.restoreTransaction(transaction as SKPaymentTransaction)
            default:
                print("Transaction state: \(transaction.transactionState)")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("RemovedTransactions: \(transactions)")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.count == 0 {
            print("No previous purchases were restored.")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Restore previous purchases"), object: self, userInfo: ["status": "Not restored"])
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        print("UpdatedDownload: \(downloads)")
    }
}

extension SKProduct {
    var priceString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .default
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = self.priceLocale
        return numberFormatter.string(from: self.price)!
    }
}
