//
//  RateMeControllerAskStatusContainer.swift
//  RateMeForOSX
//
//  Created by Mark Cornelisse on 12/01/16.
//  Copyright © 2016 Over de muur producties. All rights reserved.
//

import Foundation

public enum RateMeControllerAskStatus: Int32, CustomStringConvertible {
    case yes, alreadyRated, no, noNever
    
    // MARK: Custom String Convertible
    public var description: String {
        switch (self) {
        case .yes:
            return "RateMeControllerAskStatus: .Yes"
        case .alreadyRated:
            return "RateMeControllerAskStatus: .AlreadyRated"
        case .no:
            return "RateMeControllerAskStatus: .No"
        case .noNever:
            return "RateMeControllerAskStatus: .NoNever"
        }
    }
}

private let kRateMeControllerAskStatusContainerShouldAsk = "kRateMeControllerAskStatusContainerShouldAsk"
private let kRateMeControllerAskStatusContainerLastVersion = "kRateMeControllerAskStatusContainerLastVersion"

final internal class RateMeControllerAskStatusContainer: NSObject, NSSecureCoding {
    var shouldAsk: RateMeControllerAskStatus
    var lastVersion: String?
    
    // MARK: New in this class
    
    init(shouldAsk: RateMeControllerAskStatus, lastVersion: String?) {
        self.shouldAsk = shouldAsk
        self.lastVersion = lastVersion
        super.init()
    }
    
    // MARK: Inherited from super
    
    override convenience init() {
        self.init(shouldAsk: RateMeControllerAskStatus.yes, lastVersion: nil)
    }
    
    // MARK: NSSecureCoding
    
    static var supportsSecureCoding: Bool = false
    
    // MARK: NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.shouldAsk = RateMeControllerAskStatus(rawValue: aDecoder.decodeInt32(forKey: kRateMeControllerAskStatusContainerShouldAsk))!
        self.lastVersion = aDecoder.decodeObject(forKey: kRateMeControllerAskStatusContainerLastVersion) as? String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.shouldAsk.rawValue, forKey: kRateMeControllerAskStatusContainerShouldAsk)
        if let lastVersion = lastVersion {
            aCoder.encode(lastVersion, forKey: kRateMeControllerAskStatusContainerLastVersion)
        }
    }
}
