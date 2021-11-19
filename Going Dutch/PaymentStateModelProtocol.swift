//
//  PaymentStateModelProtocol.swift
//  We all pay
//
//  Created by Mark Cornelisse on 19/11/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import Foundation

/// Exposes a paymentModel through the responder chain. 
@objc(MCPaymentStateModelProtocol) protocol PaymentStateModelProtocol {
    var paymentStateModel: PaymentModel { get }
}
