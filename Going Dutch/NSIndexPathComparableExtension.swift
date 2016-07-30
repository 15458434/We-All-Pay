//
//  NSIndexPathComparableExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 29/07/16.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit

extension NSIndexPath: Comparable { }

public func ==(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    let result = lhs.compare(rhs)
    return result == NSComparisonResult.OrderedSame
}

public func <(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    let result = lhs.compare(rhs)
    return result == NSComparisonResult.OrderedAscending
}