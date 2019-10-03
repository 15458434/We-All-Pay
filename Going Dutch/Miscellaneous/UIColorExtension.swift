//
//  UIColorExtension.swift
//  Bift
//
//  Created by Mark Cornelisse on 13/08/15.
//  Copyright (c) 2015 Over de muur producties. All rights reserved.
//

import UIKit

public extension UIColor {
    class func eightBit(_ red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) -> UIColor {
        func convert(_ i: UInt8) -> CGFloat {
            return CGFloat(i)/255.0
        }
        func convertAlpha(_ i: UInt8) -> CGFloat {
            return CGFloat(i)/100.0
        }
        return UIColor(red: convert(red), green: convert(green), blue: convert(blue), alpha: convertAlpha(alpha))
    }
    
    class func eightBit(_ white: UInt8, alpha: UInt8) -> UIColor {
        func convert(_ i: UInt8) -> CGFloat {
            return CGFloat(i)/255.0
        }
        func convertAlpha(_ i: UInt8) -> CGFloat {
            return CGFloat(i)/100.0
        }
        return UIColor(white: convert(white), alpha: convertAlpha(100))
    }
}
