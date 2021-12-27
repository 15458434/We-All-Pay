//
//  SolutionReturnPaymentItem.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/11/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc(MCReturnPayment) final class SolutionReturnPaymentItem: NSObject {
    @objc let payer: MCPerson?
    @objc let receiver: MCPerson?
    @objc let money: NSNumber?
    
    @objc init(payer: MCPerson?, money: NSNumber?, receiver: MCPerson?) {
        self.payer = payer
        self.receiver = receiver
        self.money = money
        super.init()
    }
    
    // MARK: NSObject
    
    override var description: String {
        return "\(String(describing: payer)) owes \(String(describing: money)) to \(String(describing: receiver))."
    }
}
