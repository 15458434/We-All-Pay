//
//  MCCategoryPictureStoreTest.swift
//  We all pay Tests
//
//  Created by Mark Cornelisse on 02/09/2025.
//  Copyright © 2025 Mark Cornelisse. All rights reserved.
//

@testable import We_all_pay
import XCTest

class MCCategoryPictureStoreTest: XCTestCase {

    private var myCategoryPictureController: CategoryPictureStoreController!

    override func setUp() {
        super.setUp()
        myCategoryPictureController = CategoryPictureStoreController.shared
        XCTAssertNotNil(myCategoryPictureController, "Unable to create Shared Instance")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPreparePictureArray() {
//        myCategoryPictureController.preparePictureObjectsArray()
        XCTAssertNotNil(myCategoryPictureController.pictureObjects, "Picture array not created.")
    }

    func testCategoryPictureInitWithDictionary() {
        let testDictionary: [String: AnyObject] = [
            "categoryId"                : NSNumber(value: 45),
            "categoryPictureFilename"   : "MyFileName" as NSString,
            "categoryDescription"       : "Groceries" as NSString
        ]
        let myTestObject = CategoryPictureObject(dictionary: testDictionary)
        XCTAssertTrue(myTestObject.categoryId == 45, "Invalid categoryId")
        XCTAssertNotNil(myTestObject.categoryDescription, "CategoryDescription is not supposed to be nil")
        XCTAssertNotNil(myTestObject.pictureFilename, "pictureFilename is not supposed to be nil")
    }
}
