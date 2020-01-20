//
//  CategoryPictureStoreController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/12/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

final class CategoryPictureStoreController: NSObject {
    @objc enum PaymentCategory: Int {
        case none = 0
        case dinner = 1
        case drinks = 2
        case fuel = 3
        case groceries = 4
        case hotel = 5
        case tickets = 6
        case rent = 7
        case spaAndRelaxation = 8
        case travel = 9
        case miscellaneous = 10
        case present = 11
        
        var number: NSNumber {
            return NSNumber(value: self.rawValue)
        }
    }
    // MARK: Properties
    @objc var pictureObjects: [CategoryPictureObject] {
        let plistPath = Bundle.main.path(forResource: "categoryPictures", ofType: "plist")!
        let arrayFromPlist = NSArray(contentsOfFile: plistPath) as! [Dictionary<String, AnyObject>]
        
        return arrayFromPlist.map({ (dictionary) -> CategoryPictureObject in
            return CategoryPictureObject(dictionary: dictionary)
        })
    }
    
    // MARK: SingleTon
    @objc static let shared = CategoryPictureStoreController()
    
//    func preparePictureObjectsArray() {
//        let plistPath = NSBundle.mainBundle().pathForResource("categoryPictures", ofType: "plist")!
//        let arrayFromPlist = NSArray(contentsOfFile: plistPath) as! [Dictionary<String, AnyObject>]
//        
//        pictureObjects = arrayFromPlist.map({ (dictionary) -> CategoryPictureObject in
//            return CategoryPictureObject(dictionary: dictionary)
//        })
//    }
}
