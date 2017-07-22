//
//  CategoryPictureStoreController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/12/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

class CategoryPictureStoreController: NSObject {
    // MARK: Properties
    var pictureObjects: [CategoryPictureObject] {
        let plistPath = Bundle.main.path(forResource: "categoryPictures", ofType: "plist")!
        let arrayFromPlist = NSArray(contentsOfFile: plistPath) as! [Dictionary<String, AnyObject>]
        
        return arrayFromPlist.map({ (dictionary) -> CategoryPictureObject in
            return CategoryPictureObject(dictionary: dictionary)
        })
    }
    
    // MARK: SingleTon
    static let sharedController = CategoryPictureStoreController()
    
//    func preparePictureObjectsArray() {
//        let plistPath = NSBundle.mainBundle().pathForResource("categoryPictures", ofType: "plist")!
//        let arrayFromPlist = NSArray(contentsOfFile: plistPath) as! [Dictionary<String, AnyObject>]
//        
//        pictureObjects = arrayFromPlist.map({ (dictionary) -> CategoryPictureObject in
//            return CategoryPictureObject(dictionary: dictionary)
//        })
//    }
}
