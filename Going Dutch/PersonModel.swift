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
    
    @objc(initWithPerson:) convenience init(with person: MCPerson) {
        self.init()
        prepareForUse(withPerson: person)
    }
    
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
        guard let defaultEmailAddressObject = person.defaultEmailAddressObject else {
            return NSNotFound
        }
        return emailaddresses.firstIndex(of: defaultEmailAddressObject) ?? NSNotFound
    }

    func beginUpdates() {
        person.managedObjectContext!.undoManager!.beginUndoGrouping()
    }
    
    private func addEmailAddress() -> MCEmailAddress {
        let new = MCEmailAddress(context: self.person.managedObjectContext!)
        new.owner = person
        person.addToEmailAddress(new)
        return new
    }
    
    @objc(addOneEmailAddressFromAString:) func add(emailAddress newEmailAddress: String) {
        let request = MCEmailAddress.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCEmailAddress.emailAddress, ascending: true)]
        request.predicate = NSPredicate(format: "emailAddress = %@ AND owner = %@", newEmailAddress, person)
        
        do {
            let amountOfEqualEmailAddresses = try person.managedObjectContext?.count(for: request)
            if amountOfEqualEmailAddresses == 0 {
                let newEmailObject = addEmailAddress()
                
                newEmailObject.selected = NSNumber(value: (person.emailAddress!.count == 1))
                newEmailObject.emailAddress = newEmailAddress
                let now = Date()
                newEmailObject.dateModified = now
                person.dateModified = now
            }
        } catch {
            print("something went wrong in the search for equal email addresses")
        }
    }
    
    @objc(addNewDefaultEmailAddressFromAString:) func add(defaultEmailAddress newDefaultEmailAddress: String) {
        let now = Date()
        if let oldDefaultEmailAddress = self.defaultEmailaddress {
            oldDefaultEmailAddress.selected = NSNumber(value: false)
            oldDefaultEmailAddress.dateModified = now
        }
        let newEmailAddress = addEmailAddress()
        newEmailAddress.selected = NSNumber(value: true)
        newEmailAddress.emailAddress = newDefaultEmailAddress
        person.dateModified = now
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
            self.add(emailAddress: defaultEmailAddress)
        }
        person.dateModified = nu
    }
    
    @objc(updateDefaultEmailAddressObject:) public func update(default newEmailaddress: MCEmailAddress) {
        // TODO: Write test function for this test.
        let previousDefaultEmailAddressObject = person.defaultEmailAddressObject
        previousDefaultEmailAddressObject?.selected = NSNumber(value: false)
        newEmailaddress.selected = NSNumber(value: true)
        let now = Date()
        newEmailaddress.dateModified = now
        previousDefaultEmailAddressObject?.dateModified = now
        self.changeHandler?(self.person)
    }
    
    @objc(deleteEmailAddress:) func delete(_ emailAddress: MCEmailAddress) {
        if emailAddress.selected?.boolValue ?? false {
            let newDefault = (person.emailAddress as? Set<MCEmailAddress>)?.first(where: { $0.selected == NSNumber(value: false)
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
        if let emailAdresses = person.emailAddress as? Set<MCEmailAddress> {
            let emailAddressesWithoutEmailAddress = emailAdresses.filter { $0.objectID != emailAddress.objectID }
            person.emailAddress = emailAddressesWithoutEmailAddress as NSSet
        }
        person.managedObjectContext?.delete(emailAddress)
    }
    
    func endUpdates() {
        person.sharedBill?.forEach({ event in
            let event = event as! MCSharedBill
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
