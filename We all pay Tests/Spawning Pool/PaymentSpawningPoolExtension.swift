//
//  PaymentSpawningPoolExtension.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 21/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import Foundation

import CurrencyConverter

extension PaymentSpawningPool {
    func dinner(selectPayer: MCPerson?, selectCurrencyCode: String? = nil, money: NSNumber?) -> MCPayment {
        let dinnerCategory = CategoryPictureStoreController.shared.pictureObjects.first { $0.categoryId == 1 }
        let newPayment = createPayment(
            selectPayer: selectPayer,
            selectCategory: dinnerCategory,
            descriptionOfPayment: "Giant Steak Menu",
            selectCurrency: selectCurrencyCode,
            money: money == nil ? NSNumber(value: 119.99) : money)
        return newPayment
    }
}
