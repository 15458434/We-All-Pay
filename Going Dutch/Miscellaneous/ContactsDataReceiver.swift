//
//  ContactsDataReceiver.swift
//  We all pay
//
//  Created by Mark Cornelisse on 12/09/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit
import ContactsUI

class ContactsDataReceiver: NSObject, ThisEventReadOnly, CNContactPickerDelegate {
    
    @objc init(with tonightsBill: MCSharedBill) {
        self.event = tonightsBill
        super.init()
    }
    
    @objc func presentContactsPicker(with viewController: UIViewController, completion: ( () -> Swift.Void)? = nil) {
        let contactsViewController = CNContactPickerViewController()
        contactsViewController.delegate = self
        contactsViewController.displayedPropertyKeys = [CNContactGivenNameKey,
                                                        CNContactFamilyNameKey,
                                                        CNContactMiddleNameKey,
                                                        CNContactEmailAddressesKey,
                                                        CNContactImageDataKey,
                                                        CNContactIdentifierKey,
                                                        CNContactNoteKey]
        contactsViewController.modalPresentationStyle = .formSheet
        viewController.present(contactsViewController, animated: true) {
            debugPrint("Hooray, the contacts form on the screen.")
            completion?()
        }
    }
    
    // MARK: ThisEventReadOnly
    
    let event: MCSharedBill
    
    // MARK: CNContactPickerDelegate
    
    @objc func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let tonightsBillID: NSManagedObjectID = event.objectID
        let backgroundContext: NSManagedObjectContext = MCWeAllPayStoreController.defaultStore().backgroundThreadContext!
        
        backgroundContext.perform {
            let backgroundTonightsBill: MCSharedBill = backgroundContext.object(with: tonightsBillID) as! MCSharedBill
            let newPerson: MCPerson = backgroundTonightsBill.addPerson()!
            newPerson.firstName = contact.givenName
            newPerson.lastName = contact.middleName + contact.familyName
            for emailAddress in contact.emailAddresses {
                let emailAddressString = emailAddress.value as String
                newPerson.addOneEmailAddress(fromAString: emailAddressString)
            }
            if let imageData = contact.imageData {
                newPerson.setThumbnailDataFrom(UIImage(data: imageData)!)
                newPerson.setPictureDataFrom(UIImage(data: imageData)!)
            } else {
                newPerson.setThumbnailDataFrom(nil)
                newPerson.setPictureDataFrom(nil)
            }
            
            MCWeAllPayStoreController.defaultStore().savebackgroundContext()
        }
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        debugPrint("Whatever")
    }
    
    // MARK: NSObject
}
