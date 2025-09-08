//
//  SequenceExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 06/05/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation

extension Sequence where Element: MCPayment {
    var totalSumOfMoneyInMainCurrency: NSDecimalNumber {
        let result = self.reduce(NSDecimalNumber(value: 0)) { partialResult, payment in
            let moneyInMainCurrencyDecimal = NSDecimalNumber(decimal: payment.moneyInMainCurrency.decimalValue)
            let result = partialResult.adding(moneyInMainCurrencyDecimal)
            return result
        }
        return result
    }
}
