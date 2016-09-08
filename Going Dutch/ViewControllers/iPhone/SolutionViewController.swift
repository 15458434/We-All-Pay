//
//  ReturnPaymentViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit

class SolutionViewController: MCReturnPaymentViewController, ThisEvent, ShowMailViewProtocol {
    
    // MARK: New in this class
    override func openMailView(_ sender: Any!) {
        self.showMailView(sender as AnyObject)
    }
    
    // MARK: ThisEvent
    var event: MCSharedBill! {
        set {
            tonightsBill = newValue
        }
        get {
            return tonightsBill
        }
    }
    
    // MARK: ShowMailViewProtocol
}
