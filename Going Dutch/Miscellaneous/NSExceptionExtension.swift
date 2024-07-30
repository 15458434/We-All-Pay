//
//  NSExceptionExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 06/08/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

import Foundation

extension NSException {
    @objc(initWithError:) convenience init(error: NSError) {
        self.init(name: NSExceptionName(rawValue: error.domain), reason: error.localizedDescription, userInfo: error.userInfo)
    }
    
    @objc(exceptionWithError:) class func exception(error: NSError) -> NSException {
        return NSException(error: error)
    }
}
