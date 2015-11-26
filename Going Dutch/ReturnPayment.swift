//
//  ReturnPayment.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/11/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

class ReturnPayment: NSObject {
    // MARK: Properties
    let payer: MCPerson?
    let receiver: MCPerson?
    let money: NSNumber?
    
    init(payer: MCPerson?, money: NSNumber?, receiver: MCPerson?) {
        self.payer = payer
        self.receiver = receiver
        self.money = money
        super.init()
    }
    
    // MARK: Inherited from super.
    override var description: String {
        return "\(payer) owes \(money) to \(receiver)."
    }
}