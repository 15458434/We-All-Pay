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
    private var changeHandler: ((_ person: MCPerson) -> ())!
    
    @objc(prepareForUseWithPerson:andChangeHandler:) func prepareForUse(with person: MCPerson, and changeHandler:@escaping ((_ person: MCPerson) -> ())) {
        self.person = person
        self.changeHandler = changeHandler
        self.changeHandler(self.person)
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
    
    @objc(updateDefaultEmailAddress:) func update(defaultEmailAddress: String) {
        person.addNewDefaultEmailAddress(fromAString: defaultEmailAddress)
    }
    
    func endUpdates() {
        person.managedObjectContext!.undoManager!.endUndoGrouping()
        self.changeHandler(self.person)
    }

    // MARK: NSObject
}
