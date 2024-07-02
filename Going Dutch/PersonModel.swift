//
//  PersonModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPersonModel) @objcMembers final class PersonModel: NSObject {
    public private(set) dynamic var person: MCPerson!
    private(set) var personFetchedResultsController: NSFetchedResultsController<MCPerson>!
    private(set) var allEmailaddressesFetchedResultsController: NSFetchedResultsController<MCEmailAddress>!
    private(set) var defaultEmailAddressFetchedResultsController: NSFetchedResultsController<MCEmailAddress>!
    private var changeHandler: ((_ person: MCPerson) -> ())!
    
    @objc(prepareForUseWithPerson:andFetchedResultsControllerDelegate:andChangeHandler:) func prepareForUse(with person: MCPerson, and fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate, and changeHandler:@escaping ((_ person: MCPerson) -> ())) {
        func createPersonFetchedResultsController() {
            let request = MCPerson.fetchRequest()
            request.predicate = NSPredicate(format: "self = %@", person)
            request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
            personFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: person.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            personFetchedResultsController.delegate = fetchedResultsControllerDelegate
            try! personFetchedResultsController.performFetch()
        }
        func createAllEmailAddressesFetchedResultsController() {
            let request = MCEmailAddress.fetchRequest()
            request.predicate = NSPredicate(format: "owner = %@", person)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MCEmailAddress.emailAddress, ascending: true)]
            allEmailaddressesFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: person.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            allEmailaddressesFetchedResultsController.delegate = fetchedResultsControllerDelegate
            try! allEmailaddressesFetchedResultsController.performFetch()
        }
        func createDefaultEmailAddressResultsController() {
            let request = MCEmailAddress.fetchRequest()
            request.predicate = NSPredicate(format: "owner = %@ AND selected = %@", person, NSNumber(value: true))
            request.sortDescriptors = [NSSortDescriptor(key: "emailAddress", ascending: true)]
            defaultEmailAddressFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: person.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            defaultEmailAddressFetchedResultsController.delegate = fetchedResultsControllerDelegate
            try! defaultEmailAddressFetchedResultsController.performFetch()
        }
        
        self.person = person
        createPersonFetchedResultsController()
        createAllEmailAddressesFetchedResultsController()
        createDefaultEmailAddressResultsController()
        self.changeHandler = changeHandler
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
        self.changeHandler(self.person)
    }
    
    func endUpdates() {
        person.sharedBill?.forEach({ event in
            let mutableSet = event.mutableSetValue(forKey: "peoplePresent")
            mutableSet.add(person!)
        })
        person.managedObjectContext!.undoManager!.endUndoGrouping()
        self.changeHandler(self.person)
    }

    // MARK: NSObject
}
