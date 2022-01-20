//
//  CurrencyItem.swift
//  acpm
//
//  Created by Mark Cornelisse on 20/01/2022.
//  Copyright © 2022 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc(MCCurrencyItem) final class CurrencyItem: NSObject, NSCoding {
    @objc(name) var name: String?
    @objc(type) var type: NSNumber?
    @objc(code) var code: String?
    
    init(name: String, type: NSNumber, code: String) {
        self.name = name
        self.type = type
        self.code = code
        
        super.init()
    }
    
    // MARK: NSCoding
    
    enum Keys: String {
        case name = "name"
        case type = "type"
        case code = "code"
    }
    
    required init?(coder: NSCoder) {
        self.name = coder.decodeObject(forKey: Keys.name.rawValue) as? String
        self.type = coder.decodeObject(forKey: Keys.name.rawValue) as? NSNumber
        self.code = coder.decodeObject(forKey: Keys.name.rawValue) as? String
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name! as NSString, forKey: Keys.name.rawValue)
        coder.encode(type!, forKey: Keys.name.rawValue)
        coder.encode(code! as NSString, forKey: Keys.name.rawValue)
    }
    
    // MARK: NSObject
    
    override init() {
        super.init()
    }
    
    override var debugDescription: String {
        return "name: \(String(describing: name)), type: \(String(describing: type)), code: \(String(describing: code))"
    }
}
