//
//  MCCategoryPictureStoreTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 15/10/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MCCategoryPictureStoreController.h"
#import "MCCategoryPictureObject.h"

@interface MCCategoryPictureStoreTest : XCTestCase

@property (nonatomic, strong) MCCategoryPictureStoreController *myCategoryPictureController;

@end

@implementation MCCategoryPictureStoreTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _myCategoryPictureController = [MCCategoryPictureStoreController sharedController];
    XCTAssertTrue(_myCategoryPictureController, @"Unable to create Shared Instance");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPreparePictureArray
{
    [_myCategoryPictureController preparePictureObjectsArray];
    XCTAssertTrue([_myCategoryPictureController pictureObjects], @"Picture array not created.");
}

- (void)testCategoryPictureInitWithDictionary
{
    NSDictionary *testDictionary = @{ @"categoryId" : @45,
                                      @"categoryPictureFilename" : @"MyFileName",
                                      @"categoryDescription" : @"Groceries" };
    MCCategoryPictureObject *myTestObject = [[MCCategoryPictureObject alloc] initWithDictionary:testDictionary];
    XCTAssertTrue(myTestObject.categoryId == 45, @"Invalid categoryId");
    XCTAssertNotNil(myTestObject.categoryDescription, @"CategoryDescription is not supposed to be nil");
    XCTAssertNotNil(myTestObject.pictureFilename, @"pictureFilename is not supposed to be nil");
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
