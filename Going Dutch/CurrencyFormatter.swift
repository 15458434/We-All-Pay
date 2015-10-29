//
//  CurrencyFormatter.swift
//  We all pay
//
//  Created by Mark Cornelisse on 28/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

class CurrencyFormatter: NSFormatter {
    // MARK: Properties
    var currencyCode: String?
    
    // MARK: New in this class
    convenience init(currencyCode: String) {
        self.init()
        self.currencyCode = currencyCode
    }
    
    func doubleFromString(string: String) -> NSNumber? {
        var moneyObject: AnyObject? = nil
        var moneyErrorString: NSString? = nil
        let success = self.getObjectValue(&moneyObject, forString: string, errorDescription: &moneyErrorString)
        if success {
            let moneyNumber = moneyObject as! NSNumber
            return moneyNumber
        } else {
            if moneyErrorString != nil {
                print(moneyErrorString)
            }
            return nil
        }
    }
    
    // MARK: Inherited from super
    override init() {
        super.init()
    }
    
    override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        let nf = NSNumberFormatter()
        nf.numberStyle = .DecimalStyle
        if let nummer = nf.numberFromString(string) {
            obj.memory = nummer
            return true
        } else {
            if error != nil {
                let errorString = "Error converting to Double"
                error.memory = errorString as NSString
            }
            return false
        }
    }
    
    override func stringForObjectValue(obj: AnyObject) -> String? {
        if let nummer = obj as? NSNumber {
            let nf = NSNumberFormatter()
            nf.numberStyle = .CurrencyStyle
            if let code = currencyCode {
                nf.currencyCode = code
            }
            return nf.stringFromNumber(nummer)
        } else {
            return nil
        }
    }
    
    override func editingStringForObjectValue(obj: AnyObject) -> String? {
        if let nummer = obj as? NSNumber {
            if nummer.doubleValue == 0 {
                return nil
            }
            let nf = NSNumberFormatter()
            nf.numberStyle = .DecimalStyle
            return nf.stringFromNumber(nummer)
        } else {
            return nil
        }
    }
    
    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        self.currencyCode = aDecoder.decodeObjectForKey("kCurrencyCode") as? String
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(self.currencyCode, forKey: "kCurrencyCode")
    }
}
