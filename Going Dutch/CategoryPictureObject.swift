//
//  CategoryPictureObject.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/12/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import Foundation

private let categoryDescriptionKey = "categoryDescription"
private let categoryPictureFilenameKey = "categoryPictureFilename"
private let categoryIdKey = "categoryId"

class CategoryPictureObject: NSObject {
    // MARK: Properties
    @objc let categoryId: Int16
    @objc let pictureFilename: String
    @objc var categoryDescription: String!
    @objc var smallPicture: UIImage? {
        return UIImage(named: "\(pictureFilename)-small")
    }
    @objc var largePicture: UIImage? {
        return UIImage(named: "\(pictureFilename)-large")
    }
    
    class func object(_ dictionary: Dictionary<String, AnyObject>) -> CategoryPictureObject {
        return CategoryPictureObject(dictionary: dictionary)
    }
    
    @objc init(dictionary: Dictionary<String, AnyObject>) {
        categoryDescription = (dictionary[categoryDescriptionKey] as! String)
        let categoryNumber = dictionary[categoryIdKey] as! NSNumber
        categoryId = categoryNumber.int16Value
        pictureFilename = dictionary[categoryPictureFilenameKey] as! String
    }
}
