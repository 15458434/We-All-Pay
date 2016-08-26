//
//  SolutionTableViewController_iPad.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit

class SolutionTableViewController_iPad: MCSolutionTableViewController, ThisEvent, ShowMailViewProtocol {
    
    // MARK: New in this class
    override func openMailView(sender: AnyObject!) {
        self.showMailView(sender)
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