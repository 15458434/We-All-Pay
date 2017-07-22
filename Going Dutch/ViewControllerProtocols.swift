//
//  ViewControllerProtocols.swift
//  We all pay
//
//  Created by Mark Cornelisse on 12/04/16.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc(MCThisPersonProtocol) protocol ThisPersonProtocol {
    var thisPerson: MCPerson! {set get}
    
     @objc optional var isNew: Bool {set get}
}
