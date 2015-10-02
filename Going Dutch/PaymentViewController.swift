//
//  PaymentViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 02/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit
import CoreData

enum DidSomethingChange: Int8 {
    case NothingChanged = 0, SomethingChanged
}

enum IsNew {
    case IsNew, IsNotNew
}

enum CancelButtonPressed {
    case NotPressed, IsPressed
}

@objc class PaymentViewController: UITableViewController, MCTonightsBillTransfer, MCThisPaymentProtocol, MCDismissMeBlockProtocol, MCDismissKeyboardProtocol, MCPathComponentsToOpenProtocol, UITextFieldDelegate, UIPopoverControllerDelegate,NSFetchedResultsControllerDelegate {
    // MARK: IB Outlet
    @IBOutlet var itemField: UITextField!
    @IBOutlet var paidField: UITextField!
    @IBOutlet var categoryImage: UIImageView!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var payerView: UIImageView!
    @IBOutlet var selectButton: UIButton!
    
    // MARK: Properties
    var didSomethingChange: DidSomethingChange?
    var isNew: IsNew?
    
    var dataController: NSFetchedResultsController!
    var paymentPresenceArray: [MCPaymentPresence]!
    
    var thisPayment: MCPayment!
    var tonightsBill: MCSharedBill!
    var writableTonightsBill: MCSharedBill!
    
    var dismissMe: (()->())?
    
    var pathComponentsToOpen: [AnyObject]?
    
    var mainCancelIsPressed = CancelButtonPressed.NotPressed
    
    // MARK: IB Actions
    @IBAction func mainCancelPressed(sender: UIButton) {
        mainCancelIsPressed = .IsPressed
        dataController.delegate = nil
        if MCWeAllPayStoreController.defaultStore().mainThreadContext.undoManager?.canUndo == true {
            MCWeAllPayStoreController.defaultStore().endUndoGroupAndUndo()
        } else {
            MCWeAllPayStoreController.defaultStore().endUndoGroup()
        }
        navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        dismissMe?()
    }
    
    @IBAction func mainDonePressed(sender: UIButton) {
        let now = NSDate()
        tonightsBill.dateModified = now
        MCWeAllPayStoreController.defaultStore().endUndoGroupAndProcess()
        MCWeAllPayStoreController.defaultStore().saveMainThreadContext()
        navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        dismissMe?()
    }
    
    // MARK: New in this class
    private func reloadCategoryImageView() {
        let categoryId = thisPayment.categoryId.integerValue
        let categoryObject = MCCategoryPictureStoreController.sharedController().pictureObjects[categoryId]
        if categoryId > 0 {
            categoryImage.image = categoryObject.largePicture
        } else {
            categoryImage.image = nil
        }
    }
    
    private func setTextForCategoryButton() {
        let categoryId = thisPayment.categoryId.integerValue
        let categoryObject = MCCategoryPictureStoreController.sharedController().pictureObjects[categoryId]
        if categoryId > 0 {
            categoryImage.image = categoryObject.largePicture
            categoryButton.setTitle(categoryObject.categoryDescription, forState: .Normal)
        } else {
            categoryImage.image = nil
            let title = NSLocalizedString("Select Category", comment: "Text of the payment category selection button")
            categoryButton.setTitle(title, forState: .Normal)
        }
        categoryButton.sizeToFit()
    }
    
    private func performFetchAndReloadTableView(notification: NSNotification) {
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
        selectButton.setTitle(thisPayment.payingPerson.getFullName(), forState: .Normal)
        selectButton.sizeToFit()
    }
    
    private func respondToPresenceOfPathComponentsFromAppLaunch() {
        if pathComponentsToOpen != nil {
            tonightsBill = pathComponentsToOpen![0] as! MCSharedBill
            thisPayment = tonightsBill.addPayment()
            thisPayment.payingPerson = pathComponentsToOpen![1] as! MCPerson
        }
    }
    
    // MARK: Inherited from super
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.respondToPresenceOfPathComponentsFromAppLaunch()
        
        MCWeAllPayStoreController.defaultStore().beginUndoGroup()
        
        startResigningFirstResponderOnBackgroundTap()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if thisPayment == nil {
            thisPayment = tonightsBill.addPayment()
            let screenTitle = NSLocalizedString("New Payment", comment: "Screen name saying this is a new payment.")
            title = screenTitle
            isNew = .IsNew
        } else {
            itemField.text = thisPayment.descriptionOfPayment
            if thisPayment.money != nil {
                paidField.text = thisPayment.getMoneyValueInCurrencyAsAString()
            }
            reloadPayerView()
            setTextPayerButton()
            isNew = .IsNotNew
        }
        
        reloadCategoryImageView()
        setTextForCategoryButton()
        
        let sortDescriptor = NSSortDescriptor(key: "person.firstName", ascending: true)
        paymentPresenceArray = (thisPayment.peopleSharingPayment as NSSet).sortedArrayUsingDescriptors([sortDescriptor]) as! [MCPaymentPresence]
        
        if dataController == nil {
            dataController = MCWeAllPayStoreController.defaultStore().paymentPresenceDataControllerForDelegate(self)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        dataController = nil
    }
    
    // MARK: DismissKeyboardProtocol
    func dismissTheKeyboard() {
        let fr = view.getFirstResponder()
        fr?.resignFirstResponder()
    }
    
    // MARK: UITextFieldDelegate 
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == paidField {
            if thisPayment.money.doubleValue >= 0.005 {
                paidField.text = ""
            } else {
                paidField.text = thisPayment.getMoneyValueAsAString()
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if mainCancelIsPressed == CancelButtonPressed.NotPressed {
            if textField == itemField {
                thisPayment.descriptionOfPayment = itemField.text
            }
            if textField == paidField {
                thisPayment.putMoneyValueAsAString(paidField.text)
                paidField.text = thisPayment.getMoneyValueInCurrencyAsAString()
            }
        }
    }
    
    // MARK: UI Popover Controller Delegate
    func popoverController(popoverController: UIPopoverController, willRepositionPopoverToRect rect: UnsafeMutablePointer<CGRect>, inView view: AutoreleasingUnsafeMutablePointer<UIView?>) {
        print("Doesn't do anything")
    }
    
    func popoverControllerShouldDismissPopover(popoverController: UIPopoverController) -> Bool {
        return true
    }
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        if thisPayment.payingPerson != nil {
            selectButton.setTitle(thisPayment.payingPerson.getFullName(), forState: .Normal)
        }
    }
    
    // MARK: NS Fetched Results Controller Delegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    // MARK: UI Table View Delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: UI Table View Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataController.fetchedObjects!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("paymentPresenceTableViewCell", forIndexPath: indexPath) as! MCPaymentPresenceTableViewCell
        let paymentPresenceForThisCell = dataController.objectAtIndexPath(indexPath) as! MCPaymentPresence
        cell.nameLabel.text = paymentPresenceForThisCell.person.getFullName()
        cell.personView.image = paymentPresenceForThisCell.person.thumbnail
        cell.theSwitch.setOn(paymentPresenceForThisCell.isPersonPresent.boolValue, animated: false)
        // TODO: Add translation stuff.
        cell.owesMoneyLabel.text = "owes \(paymentPresenceForThisCell.getCurrencyStringOfAverageOwe())"
        cell.thisCellsPaymentPresence = paymentPresenceForThisCell
        cell.keyboardDismissDelegate = self
        
        let constraintBetweenNameLabelAndPayerLabel = NSLayoutConstraint(item: selectButton, attribute: .Leading, relatedBy: .Equal, toItem: cell.nameLabel, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let constraintBetweenPictureInCellAndPictureOfPayer = NSLayoutConstraint(item: cell.personView, attribute: .Trailing, relatedBy: .Equal, toItem: categoryImage, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        tableView.addConstraints([constraintBetweenNameLabelAndPayerLabel, constraintBetweenPictureInCellAndPictureOfPayer])
        
        return cell
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier) {
        case let identifier where identifier == "selectPayer":
            let destination = segue.destinationViewController as! MCSelectPayerTableViewController_iPad
            destination.tonightsBill = tonightsBill
            destination.thisPayment = thisPayment
            
            let myPopover = (segue as! UIStoryboardPopoverSegue).popoverController
            myPopover.delegate = self
            destination.dismissMe = {
                myPopover.dismissPopoverAnimated(true)
                self.reloadPayerView()
            }
        case let identifier where identifier == "openSelectCurrency":
            let destination = segue.destinationViewController as! MCSelectCurrencyTableViewController_iPad
            destination.thisPayment = thisPayment
            
            let myPopover = (segue as! UIStoryboardPopoverSegue).popoverController
            myPopover.delegate = self
            destination.dismissMe = { 
                myPopover.dismissPopoverAnimated(true)
            }
        case let identifier where identifier == "selectCategory":
            let destination = segue.destinationViewController as! MCSelectCategoryTableViewController_iPad
            destination.thisPayment = thisPayment
            
            let myPopover = (segue as! UIStoryboardPopoverSegue).popoverController
            myPopover.delegate = self
            destination.dismissMe = {
                myPopover.dismissPopoverAnimated(true)
                self.reloadCategoryImageView()
                self.setTextForCategoryButton()
            }
        default:
            print("Unknown segue")
            abort()
        }
    }
}
