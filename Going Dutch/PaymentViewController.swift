//
//  PaymentViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 02/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit
import CoreData

import FirebaseAnalytics

import WhoPayingUserDefaultsStoreInterface


enum DidSomethingChange: Int8 {
    case nothingChanged = 0, somethingChanged
}

enum IsNew {
    case isNew, isNotNew
}

enum CancelButtonPressed {
    case notPressed, isPressed
}

final class PaymentViewController: MCGenericAdBannerTableViewController, AdBannerEngineDelegate, MCDismissKeyboardProtocol, MCPathComponentsToOpenProtocol, UITextFieldDelegate, NSFetchedResultsControllerDelegate, PaymentStateModelProtocol {

    // MARK: IB Outlet
    @IBOutlet weak var headerView: UITableViewHeaderFooterView!
    @IBOutlet weak var itemField: UITextField!
    @IBOutlet weak var paidField: UITextField!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var payerView: UIImageView!
    @IBOutlet weak var selectPayerButton: UIButton!
    @IBOutlet weak var selectCurrencyButton: RoundedButton!
    @IBOutlet weak var presenceListLabel: UILabel!
    
    @IBOutlet var model: PaymentModel!
    
    // MARK: Properties
    var didSomethingChange: DidSomethingChange?
    var isNew: IsNew?
    
    var mainCancelIsPressed = CancelButtonPressed.notPressed
    
    private var payingPersonObservation: NSKeyValueObservation!
    private var descriptionOfPaymentObservation: NSKeyValueObservation!
    private var moneyObservation:NSKeyValueObservation!
    private var categoryIdObservation: NSKeyValueObservation!
    private var currencyObservation: NSKeyValueObservation!
    
    // MARK: IB Actions
    @IBAction func mainCancelPressed(_ sender: UIButton) {
        mainCancelIsPressed = .isPressed
        if MCWeAllPayStoreController.defaultStore().mainThreadContext.undoManager?.canUndo == true {
            MCWeAllPayStoreController.defaultStore().endUndoGroupAndUndo()
        } else {
            MCWeAllPayStoreController.defaultStore().endUndoGroup()
        }
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mainDonePressed(_ sender: UIButton) {
        MCWeAllPayStoreController.defaultStore().endUndoGroupAndProcess()
        MCWeAllPayStoreController.defaultStore().saveMainThreadContext()
        navigationController!.presentingViewController!.dismiss(animated: true, completion: { () -> Void in
            WhoPayingUserDefaultsStoreInterface.sendToUserDefaultsStoreInterface(self.model.payment.onWhichBill)
        })
    }
    
    @IBAction func selectPayerButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func categoryButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func selectCurrencyPressed(_ sender: AnyObject) {
        
    }
    
    @objc(prepareForUseWithPathComponentsToOpen:) func prepareForUse(with pathComponentsToOpen: [NSManagedObject]) {
        let event = pathComponentsToOpen[0] as! MCSharedBill
        self.prepareForUse(with: event)
        let predefinedPayingPerson = pathComponentsToOpen[1] as! MCPerson
        model.update(payingPerson: predefinedPayingPerson)
    }
    
    @objc(prepareForUseWithEvent:) func prepareForUse(with event: MCSharedBill) {
        MCWeAllPayStoreController.defaultStore().beginUndoGroup()
        let newPayment = event.addPayment()!
        title = NSLocalizedString("payment_view_mainLabel_new_payment", value: "New payment", comment: "Header in the paymentView which state new Payment")
        isNew = .isNew
        model.prepareForUse(with: newPayment)
    }
    
    @objc(prepareForUseWithPayment:) func prepareForUse(with payment: MCPayment) {
        MCWeAllPayStoreController.defaultStore().beginUndoGroup()
        title = NSLocalizedString("payment_view_mainLabel_edit_payment", value: "Payment", comment: "Header in the paymentView which states payment")
        isNew = .isNotNew
        model.prepareForUse(with: payment)
    }
    
    // MARK: DismissKeyboardProtocol
    func dismissTheKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: UITextFieldDelegate 
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == paidField {
            if model.payment.money?.doubleValue ?? 0.0 <= 0.005 {
                paidField.text = ""
            } else {
                paidField.text = model.currencyFormatter.editingString(for: model.payment.money ?? NSNumber(value: 0)) ?? nil
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if mainCancelIsPressed == CancelButtonPressed.notPressed {
            switch textField {
            case itemField:
                model.update(descriptionOfPayment: itemField.text ?? "")
            case paidField:
                model.beginUpdates()
                model.update(money: model.currencyFormatter.doubleFromString(paidField.text ?? ""))
                model.endUpdates()
            default:
                debugPrint("textFieldDidEndEditing for unknown textfield: \(textField)")
            }
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        debugPrint("controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        debugPrint("didchange")
        if #available(iOS 9, *) {
            switch (type) {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .automatic)
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [indexPath!], with: .fade)
            @unknown default:
                fatalError("Unknwn value for NSFetchedResultsChangeType")
            }
        } else {
            switch (type) {
            case .insert:
                if indexPath == nil {
                    tableView.insertRows(at: [newIndexPath!], with: .fade)
                }
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .automatic)
            case .move:
                if indexPath == newIndexPath {
                    tableView.reloadRows(at: [indexPath!], with: .automatic)
                } else {
                    tableView.deleteRows(at: [indexPath!], with: .fade)
                    tableView.insertRows(at: [indexPath!], with: .fade)
                }
            @unknown default:
                fatalError("Unknwn value for NSFetchedResultsChangeType")
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        debugPrint("controllerDidChangeContent")
        tableView.endUpdates()
    }
    
    // MARK: PaymentStateModelProtocol
    
    @objc var paymentStateModel: PaymentModel {
        return self.model
    }
    
    // MARK: AdBannerEngineDelegate
    
    func adEngine(_ adEngine: AdBannerEngine?, putOnscreen bannerView: GADBannerView) {
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseOut, animations: {
            self.worstSalesPitchEverView!.alpha = 1
        }, completion: nil)
    }
    
    func adEngine(_ adEngine: AdBannerEngine?, putOffScreen bannerView: GADBannerView) {
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseOut, animations: {
            self.worstSalesPitchEverView!.alpha = 0
        }, completion: nil)
    }
    
    // MARK: GenericAdBannerTableViewController
    
    override var adUnitId: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2934735716"
        #else
        return "ca-app-pub-5354415674074435/2765341863"
        #endif
    }

    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.peoplePresenceController.fetchedObjects!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MCPaymentPresenceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "paymentPresenceTableViewCell", for: indexPath) as! MCPaymentPresenceTableViewCell
        cell.accessibilityIdentifier = "PaymentPresenceTableViewCell-\(indexPath.row)"
        
        let paymentPresenceForThisCell: MCPaymentPresence = model.peoplePresenceController.object(at: indexPath)
        cell.nameLabel.text = paymentPresenceForThisCell.person!.getFullName()
        cell.personView.image = paymentPresenceForThisCell.person!.thumbnail
        cell.theSwitch.setOn(paymentPresenceForThisCell.isPersonPresent!.boolValue, animated: false)

        let cf: CurrencyFormatter = CurrencyFormatter(currencyCode: paymentPresenceForThisCell.payment!.currency!.code!)
        let averageOweFromPayment: NSNumber = NSNumber(value: -paymentPresenceForThisCell.averageOweFromPayment!.doubleValue)
        cell.owesMoneyLabel.text = cf.string(for: averageOweFromPayment)
        cell.thisCellsPaymentPresence = paymentPresenceForThisCell
        cell.keyboardDismissDelegate = self
        
        let constraintBetweenNameLabelAndPayerLabel = NSLayoutConstraint(item: selectPayerButton!, attribute: .leading, relatedBy: .equal, toItem: cell.nameLabel, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let constraintBetweenPictureInCellAndPictureOfPayer = NSLayoutConstraint(item: cell.personView!, attribute: .trailing, relatedBy: .equal, toItem: categoryImage, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        self.tableView.addConstraints([constraintBetweenNameLabelAndPayerLabel, constraintBetweenPictureInCellAndPictureOfPayer])
        
        return cell
    }
    
    // MARK: UITableViewController
    
    // MARK: UIViewController
    
    override func loadView() {
        super.loadView()
        
        let selectPayerButtonTitle = NSLocalizedString("payment_view_button_select_payer", value: "Select payer", comment: "Button in the edit payment view that allows the user to select a new payer")
        selectPayerButton.setTitle(selectPayerButtonTitle, for: .normal)
        itemField.placeholder = NSLocalizedString("payment_view_item_description_placeholder", value: "What got paid?", comment: "A placeholder of the item description field in the edit payment view.")
        let selectCurrencyTitle = NSLocalizedString("payment_view_button_select_currency", value: "€$£¥", comment: "Text on the button that changes the currency in which the currently entered payment was made.")
        selectCurrencyButton.setTitle(selectCurrencyTitle, for: .normal)
        paidField.placeholder = NSLocalizedString("payment_view_price_placeholder", value: "How much is spent?", comment: "A placeholder of the price fireld in the edit payment view.")
        presenceListLabel.text = NSLocalizedString("payment_view_presence_list_title", value: "Presence on payment", comment: "Title of the list of people who are present on the current payment in the edit payment view.")
        
        startResigningFirstResponderOnBackgroundTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        func createKVO() {
            self.payingPersonObservation = self.observe(\.model!.payment!.payingPerson, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? MCPerson else {
                    let selectPayerButtonTitle = NSLocalizedString("payment_view_button_select_payer", value: "Select payer", comment: "Button in the edit payment view that allows the user to select a new payer")
                    mySelf.selectPayerButton.setTitle(selectPayerButtonTitle, for: .normal)
                    mySelf.selectPayerButton.invalidateIntrinsicContentSize()
                    return
                }
                
                mySelf.selectPayerButton.setTitle(newValue.getFullName(), for: .normal)
                mySelf.selectPayerButton.invalidateIntrinsicContentSize()
                
                mySelf.payerView.image = newValue.picture
            })
            self.descriptionOfPaymentObservation = self.observe(\.model!.payment!.descriptionOfPayment, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? String else {
                    return
                }
                
                mySelf.itemField.text = newValue
            })
            self.moneyObservation = self.observe(\.model!.payment!.money, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? NSNumber else {
                    mySelf.paidField.text = nil
                    return
                }
                
                mySelf.paidField.text = mySelf.model.currencyFormatter.string(for: newValue)
            })
            self.categoryIdObservation = self.observe(\.model!.payment!.categoryId, options: [.initial, .new], changeHandler: { mySelf, change in
                guard let newValue = change.newValue as? NSNumber else {
                    return
                }
                
                let categoryId = newValue.intValue
                let categoryObject = CategoryPictureStoreController.shared.pictureObjects[categoryId]
                if categoryId > 0 {
                    mySelf.categoryImage.image = categoryObject.largePicture
                    mySelf.categoryButton.setTitle(categoryObject.categoryDescription, for: .normal)
                } else {
                    mySelf.categoryImage.image = nil
                    let title = NSLocalizedString("payment_view_button_select_category", value: "Select Category", comment: "Text of the payment category selection button")
                    mySelf.categoryButton.setTitle(title, for: .normal)
                }
                
                mySelf.categoryButton.sizeToFit()
            })
            self.currencyObservation = self.observe(\.model!.payment!.currency, options: [.new], changeHandler: { mySelf, change in
                guard (change.newValue as? MCCurrency) != nil else {
                    return
                }
                
                mySelf.paidField.text = mySelf.model.currencyFormatter.string(for: mySelf.model.payment.money)
            })
        }
        super.viewWillAppear(animated)
        
        model.peoplePresenceController.delegate = self
        do {
            try model.peoplePresenceController.performFetch()
        } catch let fetchError {
            print("Error fetching from WeAllPayStorage: \(fetchError)")
        }
        
        createKVO()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        func destroyKVO() {
            self.payingPersonObservation = nil
            self.descriptionOfPaymentObservation = nil
            self.moneyObservation = nil
            self.categoryIdObservation = nil
            self.currencyObservation = nil
        }
        super.viewWillDisappear(animated)
        
        model.peoplePresenceController.delegate = nil
        
        destroyKVO()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier) {
        case let identifier where identifier == "selectPayer_iPad":
            let destination = segue.destination as! SelectPayerTableViewController_iPad
            destination.tonightsBill = model.payment.onWhichBill
            destination.thisPayment = model.payment
        case let identifier where identifier == "openSelectCurrency_iPad":
            MCWeAllPayStoreController.defaultStore().beginUndoGroupWithoutRegistration()
            let destination = segue.destination as! SelectCurrencyTableViewController
            destination.currencyUpdateModel = PaymentUpdateCurrencyModel(with: model.payment)
            
            destination.dismissMe = {
                destination.dismiss(animated: true, completion: {
                    MCWeAllPayStoreController.defaultStore().endUndoGroupAndProcessWithoutRegistration()
                })
            }
        case let identifier where identifier == "selectCategory_iPad":
            let destination = segue.destination as! SelectCategoryTableViewController
            destination.prepareForUse(with: model.payment)
            
            destination.dismissMe = {
                destination.dismiss(animated: true)
            }
        default:
            print("Unknown segue. The programmer must be stupid.")
            abort()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if (headerView.frame.self.height != size.height) {
            let x = headerView.frame.origin.x
            let y = headerView.frame.origin.y
            let width = headerView.frame.size.width
            let height = size.height
            headerView.frame = CGRect(x: x, y: y, width: width, height: height)
            self.tableView.tableHeaderView = headerView
        }
    }
    
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
