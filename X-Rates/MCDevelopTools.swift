//
//  MCDevelopTools.swift
//  We all pay
//
//  Created by Mark Cornelisse on 10/02/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

public func debugLog(logMessage: String, object: AnyObject! = nil, function: String! = nil) {
#if DEBUG
    switch (object, function) {
    case let (object, function) where (object != nil) && (function != nil):
        println("\(object) executes \(function) with \(logMessage)")
    case let (object, function) where (object == nil) && (function != nil):
        println("\(function) executes with message: \(logMessage)")
    case let (object, function) where (object != nil) && (function == nil):
        println("\(object) give message: \(logMessage)")
    default:
        println("Message: \(logMessage)")
    }
#endif
}
