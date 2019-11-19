//
//  PersonModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPersonModel) @objcMembers class PersonModel: NSObject {
    public private(set) dynamic var person: MCPerson!
    private(set) var defaultEmailAddressFetchedResultsController: NSFetchedResultsController<MCEmailAddress>!
    private var changeHandler: ((_ person: MCPerson) -> ())!
    
    @objc(prepareForUseWithPerson:andFetchedResultsControllerDelegate:andChangeHandler:) func prepareForUse(with person: MCPerson, and fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate, and changeHandler:@escaping ((_ person: MCPerson) -> ())) {
        func createEmailAddressResultsController() {
            let request = MCEmailAddress.fetchRequest()
            request.predicate = NSPredicate(format: "owner = %@ AND selected = %@", person, NSNumber(value: true))
            request.sortDescriptors = [NSSortDescriptor(key: "emailAddress", ascending: true)]
            defaultEmailAddressFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: person.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil) as? NSFetchedResultsController<MCEmailAddress>
            defaultEmailAddressFetchedResultsController.delegate = fetchedResultsControllerDelegate
            try! defaultEmailAddressFetchedResultsController.performFetch()
        }
        
        self.person = person
        createEmailAddressResultsController()
        self.changeHandler = changeHandler
    }
    
    
    var emailAddreses: [MCEmailAddress] {
        let request = MCEmailAddress.fetchRequest()
        request.predicate = NSPredicate(format: "owner = %@", person)
        request.sortDescriptors = [NSSortDescriptor(key: "emailAddress", ascending: true)]
        let result = try! person.managedObjectContext!.fetch(request) as! [MCEmailAddress]
        return result
    }
    
    var indexOfDefaultEmailAddress: Int {
        guard let defaultEmailAddressObject = person.getDefaultEmailAddressObject() else {
            return -1
        }
        return emailAddreses.firstIndex(of: defaultEmailAddressObject) ?? -1
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
    
    @objc(updateDefaultEmailAddressWithString:) func update(defaultEmailAddress: String) {
        var defaultEmailAddressObject: MCEmailAddress? {
            let request: NSFetchRequest<MCEmailAddress> = MCEmailAddress.fetchRequest() as! NSFetchRequest<MCEmailAddress>
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
    
    @objc(updateDefaultEmailAddressWithEmailAddress:) func update(defaultEmailAddress: MCEmailAddress) {
        person.setNewDefaultEmailaddressObject(defaultEmailAddress)
    }
    
    func endUpdates() {
        person.managedObjectContext!.undoManager!.endUndoGrouping()
        self.changeHandler(self.person)
    }

    // MARK: NSObject
}
