//
//  PersonFormatter.swift
//  We all pay
//
//  Created by Mark Cornelisse on 16/09/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import Foundation

private let kPersonFormatterType: String = "kPersonFormatterType"
private let kApproxPeoplePresentFormatterType: String = "kApproxPeoplePresentFormatterType"

@objc(MCPersonFormatterType) enum PersonFormatterType: Int {
    case fullName
    case name
}

@objc(MCNameFormatter) class NameFormatter: Formatter {
    var type: PersonFormatterType = .fullName
    
    init(for type: PersonFormatterType) {
        self.type = type
        super.init()
    }
    
    private func fullName(for person: MCPerson) -> String {
        switch (person) {
        case let person where (person.firstName != nil) && (person.lastName != nil):
            return "\(person.firstName!) \(person.lastName!)"
        case let person where (person.firstName != nil) && (person.lastName == nil):
            return "\(person.firstName!)"
        case let person where (person.firstName == nil) && (person.lastName != nil):
            return "\(person.lastName!)"
        case let person where (person.firstName == nil) && (person.lastName == nil) && (person.defaultEmailAddress() != nil):
            return person.defaultEmailAddress()
        default:
            return "..."
        }
    }
    
    private func name(for person: MCPerson) -> String {
        switch (person) {
        case let person where person.firstName != nil:
            return person.firstName
        case let person where person.lastName != nil:
            return person.lastName
        case let person where person.defaultEmailAddress() != nil:
            return person.defaultEmailAddress()
        default:
            return "..."
        }
    }
    
    // MARK - Formatter
    
    override func string(for obj: Any?) -> String? {
        if let person = obj as? MCPerson {
            switch self.type {
            case .fullName:
                return fullName(for: person)
            case .name:
                return name(for: person)
            }
        }
        return nil
    }
    
    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        self.type = aDecoder.decodeObject(forKey: kPersonFormatterType) as! PersonFormatterType
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.type, forKey: kPersonFormatterType)
    }
}

//@objc (MCApproxPeoplePresentFormatter) class ApproxPeoplePresentFormatter: Formatter {
//    let nameFormatter: NameFormatter
//    
//    init(for type: PersonFormatterType) {
//        self.nameFormatter = NameFormatter(for: type)
//        super.init()
//    }
//    
//    // MARK - Formatter
//    
//    override func string(for obj: Any?) -> String? {
//        if let event = obj as? MCSharedBill {
//            let allPeople =
//            switch self.nameFormatter.type {
//            case .fullName:
//                
//            case .name:
//                
//            }
//        }
//        return nil
//    }
//    
//    // MARK: NSCoding
//    required init?(coder aDecoder: NSCoder) {
//        self.nameFormatter = aDecoder.decodeObject(forKey: kApproxPeoplePresentFormatterType) as! ApproxPeoplePresentFormatter
//        super.init(coder: aDecoder)
//    }
//    
//    override func encode(with aCoder: NSCoder) {
//        super.encode(with: aCoder)
//        aCoder.encode(self.nameFormatter, forKey: kApproxPeoplePresentFormatterType)
//    }
//
//}
