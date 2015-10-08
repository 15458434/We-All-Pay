//: Playground - noun: a place where people can play

import Foundation

class NSCurrencyFormatter: NSNumberFormatter {
    
}

let money = 34.99
let nf = NSNumberFormatter()
nf.numberStyle = NSNumberFormatterStyle.CurrencyStyle

let printedMoneyString = nf.stringFromNumber(NSNumber(double: money))
let editableMoneyString = nf.editingStringForObjectValue(NSNumber(double: money))