//
//  MCPaymentPresenceExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 12/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation
import CoreData

extension MCPaymentPresence {
    // Transient property
    @objc public var averageOweFromPaymentInMainCurrency: NSDecimalNumber {
        let averageOweFromPaymentDecimal = self.averageOweFromPayment!.decimalValue
        let exchangeRateDecimal: Decimal = self.payment!.exchangeRate!.exchangeRate!.decimalValue
        return NSDecimalNumber(decimal: averageOweFromPaymentDecimal * exchangeRateDecimal)
    }
}
