//
//  CurrencyUpdateModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc protocol CurrencyUpdateModel {
    var currencyCode: String { get }
    func updateCurrency(with code: String, with completion: @escaping ((_ error: Error?) -> Void))
    var recentSelectedCurrencies: [MCCurrency] { get }
}
