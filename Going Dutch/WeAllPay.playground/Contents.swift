//: Playground - noun: a place where people can play

import Foundation

let money = 34.99
let nf = NumberFormatter()
nf.numberStyle = .currency
nf.currencyCode = "EUR"
let symbol = nf.currencySymbol