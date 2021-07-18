//
//  CurrencyFormatter.swift
//  We all pay
//
//  Created by Mark Cornelisse on 28/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

final class CurrencyFormatter: Formatter {
    var currencyCode: String?
    
    @objc convenience init(currencyCode: String) {
        self.init()
        self.currencyCode = currencyCode
    }
    
    @objc func doubleFromString(_ string: String) -> NSNumber? {
        var moneyObject: AnyObject? = nil
        var moneyErrorString: NSString? = nil
        let success = self.getObjectValue(&moneyObject, for: string, errorDescription: &moneyErrorString)
        if success {
            let moneyNumber = moneyObject as! NSNumber
            return moneyNumber
        } else {
            if moneyErrorString != nil {
                print(moneyErrorString!)
            }
            return nil
        }
    }
    
    // MARK: Formatter
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        if let nummer = nf.number(from: string) {
            obj?.pointee = nummer
            return true
        } else {
            if error != nil {
                let errorString = "Error converting to Double"
                error?.pointee = errorString as NSString
            }
            return false
        }
    }
    
    @objc override func string(for obj: Any?) -> String? {
        if let nummer = obj as? NSNumber {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            if let code = currencyCode {
                nf.currencyCode = code
            }
            return nf.string(from: nummer)
        } else {
            return nil
        }
    }
    
    @objc override func editingString(for obj: Any) -> String? {
        if let nummer = obj as? NSNumber {
            if nummer.doubleValue == 0 {
                return nil
            }
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            return nf.string(from: nummer)
        } else {
            return nil
        }
    }
    
    // MARK: NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.currencyCode = aDecoder.decodeObject(forKey: "kCurrencyCode") as? String
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.currencyCode, forKey: "kCurrencyCode")
    }
    
    // MARK: NSObject
    
    override init() {
        super.init()
    }
}
