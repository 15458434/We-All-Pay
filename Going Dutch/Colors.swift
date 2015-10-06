//
//  Colors.swift
//  We all pay
//
//  Created by Mark Cornelisse on 06/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

class Colors: NSObject {
    class func getbackgroundColor() -> UIColor {
        return MCTools.colorWith8BitRed(213, green: 236, blue: 253, alpha: 1.0)
    }
    
    class func getButtonColor() -> UIColor {
        return MCTools.colorWith8BitRed(255, green: 135, blue: 173, alpha: 1.0)
    }
    
    class func getButtonDisabledColor() -> UIColor {
        return MCTools.colorWith8BitRed(255, green: 222, blue: 228, alpha: 1.0)
    }
    
    class func getNavigationColor() -> UIColor {
        return MCTools.colorWith8BitRed(0, green: 51, blue: 102, alpha: 1.0)
    }
    
    class func getEmptyMessageTextColor() -> UIColor {
        return MCTools.colorWith8BitRed(120, green: 165, blue: 193, alpha: 1.0)
    }
}