//
//  PersonModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPersonModel) @objcMembers final class PersonModel: NSObject {
    public private(set) var person: MCPerson!
    private(set) var personFetchedResultsController: NSFetchedResultsController<MCPerson>!
    private(set) var allEmailaddressesFetchedResultsController: NSFetchedResultsController<MCEmailAddress>!
    private(set) var defaultEmailAddressFetchedResultsController: NSFetchedResultsController<MCEmailAddress>!
    private var changeHandler: ((_ person: MCPerson) -> ())?
    
    @objc(prepareForUseWithPerson:andFetchedResultsControllerDelegate:andChangeHandler:) func prepareForUse(withPerson person: MCPerson, andFetchedResultsControllerDelegate fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate, andChangeHandler changeHandler:@escaping ((_ person: MCPerson) -> ())) {
        self.person = person
        createPersonFetchedResultsController(for: fetchedResultsControllerDelegate)
        createAllEmailAddressesFetchedResultsController(for: fetchedResultsControllerDelegate)
        createDefaultEmailAddressResultsController(for: fetchedResultsControllerDelegate)
        self.changeHandler = changeHandler
    }
    
    func prepareForUse(withPerson person: MCPerson) {
        self.person = person
    }

    func createPersonFetchedResultsController(for fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate) {
        let request = MCPerson.fetchRequest()
        request.predicate = NSPredicate(format: "self = %@", person)
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        personFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: person.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        personFetchedResultsController.delegate = fetchedResultsControllerDelegate
        try! personFetchedResultsController.performFetch()
    }
    func createAllEmailAddressesFetchedResultsController(for fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate) {
        let request = MCEmailAddress.fetchRequest()
        request.predicate = NSPredicate(format: "owner = %@", person)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCEmailAddress.emailAddress, ascending: true)]
        allEmailaddressesFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: person.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        allEmailaddressesFetchedResultsController.delegate = fetchedResultsControllerDelegate
        try! allEmailaddressesFetchedResultsController.performFetch()
    }
    func createDefaultEmailAddressResultsController(for fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate) {
        let request = MCEmailAddress.fetchRequest()
        request.predicate = NSPredicate(format: "owner = %@ AND selected = %@", person, NSNumber(value: true))
        request.sortDescriptors = [NSSortDescriptor(key: "emailAddress", ascending: true)]
        defaultEmailAddressFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: person.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        defaultEmailAddressFetchedResultsController.delegate = fetchedResultsControllerDelegate
        try! defaultEmailAddressFetchedResultsController.performFetch()
    }
    
    var emailaddresses: [MCEmailAddress] {
        let request = MCEmailAddress.fetchRequest()
        request.predicate = NSPredicate(format: "owner = %@", person)
        request.sortDescriptors = [NSSortDescriptor(key: "emailAddress", ascending: true)]
        let result = try! person.managedObjectContext!.fetch(request)
        return result
    }
    
    var defaultEmailaddress: MCEmailAddress? {
        emailaddresses.first(where: { $0.selected!.boolValue })
    }
    
    var indexOfDefaultEmailAddress: Int {
        guard let defaultEmailAddressObject = person.getDefaultEmailAddressObject() else {
            return -1
        }
        return emailaddresses.firstIndex(of: defaultEmailAddressObject) ?? -1
    }
    
    var fullName: String {
        person.getFullName()
    }
    
    var areAllExchangeRatesPresent: Bool {
        person.hasPersonMadePaymentWithInvalidExchangeRates()
    }
    
    func beginUpdates() {
        person.managedObjectContext!.undoManager!.beginUndoGrouping()
    }
    
    @objc(updateFirstName:) func update(firstName: String?) {
        let nu = Date()
        person.firstName = firstName
        person.dateModified = nu
    }
    
    @objc(updateFamilyName:) func update(familyName: String?) {
        let nu = Date()
        person.lastName = familyName
        person.dateModified = nu
    }
    
    @objc(updateDefaultEmailAddressWithString:) public func update(defaultEmailAddress: String) {
        var defaultEmailAddressObject: MCEmailAddress? {
            let request: NSFetchRequest<MCEmailAddress> = MCEmailAddress.fetchRequest()
            request.predicate = NSPredicate(format: "owner = %@ AND selected = %@", person, NSNumber(value: true))
            request.sortDescriptors = [NSSortDescriptor(key: "uniqueEmailId", ascending: true)]
            let emailAddresses = try! person.managedObjectContext!.fetch(request)
            return emailAddresses.first
        }
        
        let nu = Date()
        if let defaultEmailAddressObject = defaultEmailAddressObject {
            defaultEmailAddressObject.emailAddress = defaultEmailAddress
            defaultEmailAddressObject.dateModified = nu
        } else {
            person.addOneEmailAddress(fromAString: defaultEmailAddress)
        }
        person.dateModified = nu
    }
    
    @objc(updateDefaultEmailAddressObject:) public func update(default newEmailaddress: MCEmailAddress) {
        // TODO: Write test function for this test.
        person.setNewDefaultEmailaddressObject(newEmailaddress)
        self.changeHandler?(self.person)
    }
    
    @objc(deleteEmailAddress:) func delete(_ emailAddress: MCEmailAddress) {
        if emailAddress.selected?.boolValue ?? false {
            let newDefault = person.emailAddress?.first(where: { $0.selected == NSNumber(value: false)
            })
            newDefault?.selected = NSNumber(value: true)
        } 
        internalDelete(emailAddress)
    }
    
    @objc(deleteAllEmailAddresses) func deleteAllEmailAddresses() {
        self.emailaddresses.forEach { internalDelete($0) }
    }
    
    private func internalDelete(_ emailAddress: MCEmailAddress) {
        emailAddress.owner = nil
        if let emailAdresses = person.emailAddress {
            let emailAddressesWithoutEmailAddress = emailAdresses.filter { $0.objectID != emailAddress.objectID }
            person.emailAddress = emailAddressesWithoutEmailAddress
        }
        person.managedObjectContext?.delete(emailAddress)
    }
    
    func endUpdates() {
        person.sharedBill?.forEach({ event in
            let mutableSet = event.mutableSetValue(forKey: "peoplePresent")
            mutableSet.add(person!)
        })
        person.managedObjectContext!.undoManager!.endUndoGrouping()
        self.changeHandler?(self.person)
    }
    
    func reset() {
        person = nil
        personFetchedResultsController = nil
        allEmailaddressesFetchedResultsController = nil
        defaultEmailAddressFetchedResultsController = nil
    }

    // MARK: NSObject
}
