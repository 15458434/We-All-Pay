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
    let categoryId: Int16
    let pictureFilename: String
    var categoryDescription: String!
    var smallPicture: UIImage? {
        return UIImage(named: "\(pictureFilename)-small")
    }
    var largePicture: UIImage? {
        return UIImage(named: "\(pictureFilename)-large")
    }
    
    class func object(dictionary: Dictionary<String, AnyObject>) -> CategoryPictureObject {
        return CategoryPictureObject(dictionary: dictionary)
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        categoryDescription = dictionary[categoryDescriptionKey] as! String
        let categoryNumber = dictionary[categoryIdKey] as! NSNumber
        categoryId = categoryNumber.shortValue
        pictureFilename = dictionary[categoryPictureFilenameKey] as! String
    }
}