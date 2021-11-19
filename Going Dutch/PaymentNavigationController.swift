//
//  PaymentNavigationController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 19/11/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCPaymentNavigationController) final class PaymentNavigationController: NavigationViewController, PaymentStateModelProtocol {
    // MARK: PaymentStateModelProtocol
    
    @objc var paymentStateModel: PaymentModel {
        let viewController = self.viewControllers.last { viewController in
            let result = viewController is PaymentStateModelProtocol ? true : false
            debugPrint("result: \(result)")
            return result
        }
        return (viewController as! PaymentStateModelProtocol).paymentStateModel
    }
}
