//
//  Colors.swift
//  We all pay
//
//  Created by Mark Cornelisse on 06/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

class Colors: NSObject {
    @objc class func getbackgroundColor() -> UIColor {
        return UIColor.eightBit(213, green: 236, blue: 253, alpha: 255)
    }
    
    @objc class func getButtonColor() -> UIColor {
        return UIColor.eightBit(255, green: 135, blue: 173, alpha: 255)
    }
    
    @objc class func getButtonDisabledColor() -> UIColor {
        return UIColor.eightBit(255, green: 222, blue: 228, alpha: 255)
    }
    
    @objc class func getNavigationColor() -> UIColor {
        return UIColor.eightBit(0, green: 51, blue: 102, alpha: 255)
    }
    
    @objc class func getEmptyMessageTextColor() -> UIColor {
        return UIColor.eightBit(120, green: 165, blue: 193, alpha: 255)
    }
}
