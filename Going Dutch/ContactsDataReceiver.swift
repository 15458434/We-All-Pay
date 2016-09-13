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
    
    init(with tonightsBill: MCSharedBill) {
        self.event = tonightsBill
        super.init()
    }
    
    func presentContactsPicker(with viewController: UIViewController, completion: ( () -> Swift.Void)? = nil) {
        let contactsViewController = CNContactPickerViewController()
        contactsViewController.delegate = self
        contactsViewController.displayedPropertyKeys = [CNContactGivenNameKey,
                                                        CNContactFamilyNameKey,
                                                        CNContactMiddleNameKey,
                                                        CNContactEmailAddressesKey,
                                                        CNContactImageDataKey,
                                                        CNContactIdentifierKey,
                                                        CNContactNoteKey]
        viewController.present(contactsViewController, animated: true) {
            debugPrint("Hooray, the contacts form on the screen.")
            completion?()
        }
    }
    
    // MARK: ThisEventReadOnly
    
    let event: MCSharedBill
    
    // MARK: CNContactPickerDelegate
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        debugPrint("A person is received from the Contacts Framework: \(CNContactFormatter.string(from: contact, style: .fullName)!)")
        let tonightsBillID = event.objectID
        let backgroundContext = MCWeAllPayStoreController.defaultStore().backgroundThreadContext!
        
        backgroundContext.perform {
            let backgroundTonightsBill = backgroundContext.object(with: tonightsBillID) as! MCSharedBill
            let newPerson = backgroundTonightsBill.addPerson()!
            newPerson.firstName = contact.givenName
            newPerson.lastName = contact.middleName + contact.familyName
            for emailAddress in contact.emailAddresses {
                let emailAddressString = emailAddress.value as String
                newPerson.addOneEmailAddress(fromAString: emailAddressString)
            }
            newPerson.setThumbnailDataFrom(UIImage(data: contact.imageData!) ?? nil)
            newPerson.setPictureDataFrom(UIImage(data: contact.imageData!) ?? nil)
            MCWeAllPayStoreController.defaultStore().savebackgroundContext()
        }
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        debugPrint("Whatever")
    }
    
    // MARK: NSObject
}
