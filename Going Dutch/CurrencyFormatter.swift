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
    
    // MARK: New in this class
    
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
    override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        let nf = CFNumberFormatterCreate(kCFAllocatorDefault, CFLocaleCopyCurrent(), CFNumberFormatterStyle.DecimalStyle)
        let money: UnsafeMutablePointer<Double> = UnsafeMutablePointer<Double>.alloc(1)
        money.initialize(0.00)
        let success = CFNumberFormatterGetValueFromString(nf, string, nil, CFNumberType.DoubleType, money)
        if success {
            let nummer = NSNumber(double: money.memory)
            obj.memory = nummer
        } else {
            if error != nil {
                let errorString = "Error converting to Double"
                error.memory = errorString as NSString
            }
        }
        money.destroy()
        money.dealloc(1)
        return success
    }
    
    override func stringForObjectValue(obj: AnyObject) -> String? {
        if let nummer = obj as? NSNumber {
            let cfnf = CFNumberFormatterCreate(kCFAllocatorDefault, CFLocaleCopyCurrent(), CFNumberFormatterStyle.CurrencyStyle)
            var money: Double = nummer.doubleValue
            let cfn = CFNumberCreate(kCFAllocatorDefault, CFNumberType.DoubleType, &money)
            return CFNumberFormatterCreateStringWithNumber(kCFAllocatorDefault, cfnf, cfn) as String
        } else {
            return nil
        }
    }
    
    override func editingStringForObjectValue(obj: AnyObject) -> String? {
        if let nummer = obj as? NSNumber {
            let cfnf = CFNumberFormatterCreate(kCFAllocatorDefault, CFLocaleCopyCurrent(), CFNumberFormatterStyle.DecimalStyle)
            var money: Double = nummer.doubleValue
            let cfn = CFNumberCreate(kCFAllocatorDefault, CFNumberType.DoubleType, &money)
            return CFNumberFormatterCreateStringWithNumber(kCFAllocatorDefault, cfnf, cfn) as String
        } else {
            return nil
        }
    }
}
