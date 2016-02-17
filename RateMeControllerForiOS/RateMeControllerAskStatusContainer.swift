//
//  RateMeControllerAskStatusContainer.swift
//  RateMeForOSX
//
//  Created by Mark Cornelisse on 12/01/16.
//  Copyright © 2016 Over de muur producties. All rights reserved.
//

import Foundation

public enum RateMeControllerAskStatus: Int32, CustomStringConvertible {
    case Yes, AlreadyRated, No, NoNever
    
    // MARK: Custom String Convertible
    public var description: String {
        switch (self) {
        case .Yes:
            return "RateMeControllerAskStatus: .Yes"
        case .AlreadyRated:
            return "RateMeControllerAskStatus: .AlreadyRated"
        case .No:
            return "RateMeControllerAskStatus: .No"
        case .NoNever:
            return "RateMeControllerAskStatus: .NoNever"
        }
    }
}

private let kRateMeControllerAskStatusContainerShouldAsk = "kRateMeControllerAskStatusContainerShouldAsk"
private let kRateMeControllerAskStatusContainerLastVersion = "kRateMeControllerAskStatusContainerLastVersion"

internal class RateMeControllerAskStatusContainer: NSObject, NSCoding {
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
        self.init(shouldAsk: RateMeControllerAskStatus.Yes, lastVersion: nil)
    }
    
    // MARK: NS Coding
    
    required init?(coder aDecoder: NSCoder) {
        self.shouldAsk = RateMeControllerAskStatus(rawValue: aDecoder.decodeInt32ForKey(kRateMeControllerAskStatusContainerShouldAsk))!
        self.lastVersion = aDecoder.decodeObjectForKey(kRateMeControllerAskStatusContainerLastVersion) as? String
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt32(self.shouldAsk.rawValue, forKey: kRateMeControllerAskStatusContainerShouldAsk)
        if let lastVersion = lastVersion {
            aCoder.encodeObject(lastVersion, forKey: kRateMeControllerAskStatusContainerLastVersion)
        }
    }
}
