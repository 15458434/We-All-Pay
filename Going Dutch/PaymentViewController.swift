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

final class PaymentViewController: MCGenericAdBannerTableViewController, AdBannerEngineDelegate, MCTonightsBillTransfer, MCThisPaymentProtocol, MCDismissMeBlockProtocol, MCDismissKeyboardProtocol, MCPathComponentsToOpenProtocol, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    public var pathComponentsToOpen: [Any]!

    // MARK: IB Outlet
    @IBOutlet var itemField: UITextField!
    @IBOutlet var paidField: UITextField!
    @IBOutlet var categoryImage: UIImageView!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var payerView: UIImageView!
    @IBOutlet var selectButton: UIButton!
    
    @IBOutlet var model: PaymentModel!
    
    // MARK: Properties
    var didSomethingChange: DidSomethingChange?
    var isNew: IsNew?
    
    var dataController: NSFetchedResultsController<MCPaymentPresence>!
    var paymentPresenceArray: [MCPaymentPresence]!
    
    var thisPayment: MCPayment!
    var tonightsBill: MCSharedBill!
    var writableTonightsBill: MCSharedBill!
    
    var dismissMe: (()->())?
    
    var mainCancelIsPressed = CancelButtonPressed.notPressed
    
    // MARK: IB Actions
    @IBAction func mainCancelPressed(_ sender: UIButton) {
        mainCancelIsPressed = .isPressed
        dataController.delegate = nil
        if MCWeAllPayStoreController.defaultStore().mainThreadContext.undoManager?.canUndo == true {
            MCWeAllPayStoreController.defaultStore().endUndoGroupAndUndo()
        } else {
            MCWeAllPayStoreController.defaultStore().endUndoGroup()
        }
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        dismissMe?()
    }
    
    @IBAction func mainDonePressed(_ sender: UIButton) {
        let now = Date()
        tonightsBill.dateModified = now
        MCWeAllPayStoreController.defaultStore().endUndoGroupAndProcess()
        MCWeAllPayStoreController.defaultStore().saveMainThreadContext()
        navigationController!.presentingViewController!.dismiss(animated: true, completion: { () -> Void in
            WhoPayingUserDefaultsStoreInterface.sendToUserDefaultsStoreInterface(self.tonightsBill)
        })
        dismissMe?()
    }
    
    @IBAction func selectPayerButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func categoryButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func selectCurrencyPressed(_ sender: AnyObject) {
        
    }
    
    // MARK: New in this class
    private func reloadCategoryImageView() {
        let categoryId = thisPayment.categoryId!.intValue
        let categoryObject = CategoryPictureStoreController.shared.pictureObjects[categoryId]
        if categoryId > 0 {
            categoryImage.image = categoryObject.largePicture
        } else {
            categoryImage.image = nil
        }
    }
    
    private func setTextForCategoryButton() {
        let categoryId = thisPayment.categoryId!.intValue
        let categoryObject = CategoryPictureStoreController.shared.pictureObjects[categoryId]
        if categoryId > 0 {
            categoryImage.image = categoryObject.largePicture
            categoryButton.setTitle(categoryObject.categoryDescription, for: UIControl.State())
        } else {
            categoryImage.image = nil
            let title = NSLocalizedString("Select Category", comment: "Text of the payment category selection button")
            categoryButton.setTitle(title, for: UIControl.State())
        }
        categoryButton.sizeToFit()
    }
    
    private func performFetchAndReloadTableView(_ notification: Notification) {
        print("Should not be executed")
    }
    
    private func performFetch() throws {
        do {
            try dataController.performFetch()
        } catch let fetchError {
            print("Error fetching from WeAllPayStorage: \(fetchError)")
        }
    }
    
    func reloadPayerView() {
        setTextPayerButton()
        payerView.image = thisPayment?.payingPerson?.picture
    }
    
    private func setTextPayerButton() {
        guard let payingPerson = thisPayment.payingPerson else {
            selectButton.invalidateIntrinsicContentSize()
            return
        }
        selectButton.setTitle(payingPerson.getFullName(), for: UIControl.State())
        selectButton.invalidateIntrinsicContentSize()
    }
    
    private func respondToPresenceOfPathComponentsFromAppLaunch() {
        if pathComponentsToOpen != nil {
            tonightsBill = (pathComponentsToOpen![0] as! MCSharedBill)
            thisPayment = tonightsBill.addPayment()
            thisPayment.payingPerson = (pathComponentsToOpen![1] as! MCPerson)
        }
    }
    
    // MARK: DismissKeyboardProtocol
    func dismissTheKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: UITextFieldDelegate 
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == paidField {
            if thisPayment.money?.doubleValue ?? 0.0 <= 0.005 {
                paidField.text = ""
            } else {
                let cf = CurrencyFormatter(currencyCode: thisPayment.currency!.code!)
                paidField.text = cf.editingString(for: thisPayment.money ?? NSNumber(value: 0)) ?? nil
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
                thisPayment.descriptionOfPayment = itemField.text
            case paidField:
                let cf = CurrencyFormatter(currencyCode: thisPayment.currency!.code!)
                MCWeAllPayStoreController.defaultStore().beginUndoGroupWithoutRegistration()
                if paidField.text == nil {
                    thisPayment.money = nil
                } else {
                    thisPayment.money = cf.doubleFromString(paidField.text!)
                }
                thisPayment.recalculateAveragePeopleOweAndStore()
                MCWeAllPayStoreController.defaultStore().endUndoGroupAndProcessWithoutRegistration()
                paidField.text = cf.string(for: thisPayment.money ?? NSNumber(value: 0))
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
        return dataController.fetchedObjects!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MCPaymentPresenceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "paymentPresenceTableViewCell", for: indexPath) as! MCPaymentPresenceTableViewCell
        cell.accessibilityIdentifier = "PaymentPresenceTableViewCell-\(indexPath.row)"
        
        let paymentPresenceForThisCell: MCPaymentPresence = dataController.object(at: indexPath)
        cell.nameLabel.text = paymentPresenceForThisCell.person!.getFullName()
        cell.personView.image = paymentPresenceForThisCell.person!.thumbnail
        cell.theSwitch.setOn(paymentPresenceForThisCell.isPersonPresent!.boolValue, animated: false)

        let cf: CurrencyFormatter = CurrencyFormatter(currencyCode: paymentPresenceForThisCell.payment!.currency!.code!)
        let averageOweFromPayment: NSNumber = NSNumber(value: -paymentPresenceForThisCell.averageOweFromPayment!.doubleValue)
        cell.owesMoneyLabel.text = cf.string(for: averageOweFromPayment)
        cell.thisCellsPaymentPresence = paymentPresenceForThisCell
        cell.keyboardDismissDelegate = self
        
        let constraintBetweenNameLabelAndPayerLabel = NSLayoutConstraint(item: selectButton!, attribute: .leading, relatedBy: .equal, toItem: cell.nameLabel, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let constraintBetweenPictureInCellAndPictureOfPayer = NSLayoutConstraint(item: cell.personView!, attribute: .trailing, relatedBy: .equal, toItem: categoryImage, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        self.tableView.addConstraints([constraintBetweenNameLabelAndPayerLabel, constraintBetweenPictureInCellAndPictureOfPayer])
        
        return cell
    }
    
    // MARK: UITableViewController
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        let configEngine = RemoteConfigEngine()
        let trueCasino = RemoteConfigTrueCasino(with: configEngine, and: .percentageOfTimeShowPaymentViewBannerOniPad)
        (self.value(forKey: "adBannerEngine") as! AdBannerEngine).shouldShowEngine = trueCasino
        
        super.viewDidLoad()
        
        self.respondToPresenceOfPathComponentsFromAppLaunch()
        
        MCWeAllPayStoreController.defaultStore().beginUndoGroup()
        
        startResigningFirstResponderOnBackgroundTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if thisPayment == nil {
            thisPayment = tonightsBill.addPayment()
            let screenTitle = NSLocalizedString("New Payment", comment: "Screen name saying this is a new payment.")
            title = screenTitle
            isNew = .isNew
        } else {
            itemField.text = thisPayment.descriptionOfPayment
            if thisPayment.money != nil {
                let cf = CurrencyFormatter(currencyCode: thisPayment.currency!.code!)
                paidField.text = cf.string(for: thisPayment.money)
            }
            reloadPayerView()
            setTextPayerButton()
            isNew = .isNotNew
        }
        
        reloadCategoryImageView()
        setTextForCategoryButton()
        
        if dataController == nil {
            dataController = (MCWeAllPayStoreController.defaultStore().paymentPresenceDataController(forDelegate: self) as! NSFetchedResultsController<MCPaymentPresence>)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        dataController = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier) {
        case let identifier where identifier == "selectPayer_iPad":
            let destination = segue.destination as! SelectPayerTableViewController_iPad
            destination.tonightsBill = tonightsBill
            destination.thisPayment = thisPayment
        
            destination.dismissMe = {
                destination.dismiss(animated: true, completion: {
                    self.reloadPayerView()
                })
            }
        case let identifier where identifier == "openSelectCurrency_iPad":
            MCWeAllPayStoreController.defaultStore().beginUndoGroupWithoutRegistration()
            let destination = segue.destination as! SelectCurrencyTableViewController
            destination.currencyUpdateModel = PaymentUpdateCurrencyModel(with: thisPayment)
            
            destination.dismissMe = {
                destination.dismiss(animated: true, completion: {
                    MCWeAllPayStoreController.defaultStore().endUndoGroupAndProcessWithoutRegistration()
                })
            }
        case let identifier where identifier == "selectCategory_iPad":
            let destination = segue.destination as! SelectCategoryTableViewController
            destination.prepareForUse(with: thisPayment) { [unowned self] (payment) in
                self.reloadCategoryImageView()
                self.setTextForCategoryButton()
            }
            
            destination.dismissMe = {
                destination.dismiss(animated: true)
            }
        default:
            print("Unknown segue. The programmer must be stupid.")
            abort()
        }
    }
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
