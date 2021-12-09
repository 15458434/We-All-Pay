//
//  ThisEventProtocol.swift
//  We all pay
//
//  Created by Mark Cornelisse on 26/08/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

//import Foundation

protocol ThisEvent {
    var event: MCSharedBill! { get set }
}

protocol ThisEventReadOnly {
    var event: MCSharedBill! { get }
}
