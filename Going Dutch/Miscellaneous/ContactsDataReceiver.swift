//
//  ContactsDataReceiver.swift
//  We all pay
//
//  Created by Mark Cornelisse on 12/09/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit
import ContactsUI

final class ContactsDataReceiver: NSObject, ThisEventReadOnly, CNContactPickerDelegate {
    @objc dynamic private(set) var error: NSError?
    
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
    
    let event: MCSharedBill!
    
    // MARK: CNContactPickerDelegate
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let tonightsBillID: NSManagedObjectID = event.objectID
        WeAllPayStoreController.defaultStore.performBackgroundTask { backgroundContext in
            let backgroundTonightsBill: MCSharedBill = backgroundContext.object(with: tonightsBillID) as! MCSharedBill
            let newPerson: MCPerson = backgroundTonightsBill.addPerson()!
            let personModel = PersonModel(with: newPerson)
            personModel.person.firstName = contact.givenName
            personModel.person.lastName = contact.middleName + contact.familyName
            for emailAddress in contact.emailAddresses {
                let emailAddressString = emailAddress.value as String
                personModel.add(emailAddress: emailAddressString)
            }
            if let imageData = contact.imageData {
                newPerson.thumbnail = UIImage(data: imageData)!
                newPerson.picture = UIImage(data: imageData)!
            } else {
                newPerson.thumbnail = nil
                newPerson.picture = nil
            }
            
            do {
                try backgroundContext.save()
            } catch {
                self.error = error as NSError;
            }
        }
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        debugPrint("Whatever")
    }
    
    func resetError() {
        self.error = nil;
    }
    
    // MARK: NSObject
}
