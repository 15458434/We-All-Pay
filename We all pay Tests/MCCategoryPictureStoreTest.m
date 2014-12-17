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

- (void)testImageAvailablity
{
    NSDictionary *drinnerDictionary = @{ @"categoryId" : @1,
                                      @"categoryPictureFilename" : @"Dinner",
                                      @"categoryDescription" : @"Dinner" };
    MCCategoryPictureObject *dinnerObject = [MCCategoryPictureObject objectFromDictionary:drinnerDictionary];
    UIImage *smallImage1 = [dinnerObject smallPicture];
    XCTAssertNotNil(smallImage1, @"Small image should exist.");
    smallImage1 = [dinnerObject smallPicture];
    XCTAssertNotNil(smallImage1, @"Small image should exist.");
    UIImage *largeImage1 = [dinnerObject largePicture];
    XCTAssertNotNil(largeImage1, @"Large image should exist.");
    largeImage1 = [dinnerObject largePicture];
    XCTAssertNotNil(largeImage1, @"Large image should exist.");
    
    NSDictionary *drinksDictionary = @{ @"categoryId" : @2,
                                        @"categoryPictureFilename" : @"Drinks",
                                        @"categoryDescription" : @"Drinks" };
    MCCategoryPictureObject *drinksObject = [MCCategoryPictureObject objectFromDictionary:drinksDictionary];
    UIImage *smallImage2 = [drinksObject smallPicture];
    XCTAssertNotNil(smallImage2, @"Small image should exist.");
    smallImage2 = [drinksObject smallPicture];
    XCTAssertNotNil(smallImage2, @"Small image should exist.");
    UIImage *largeImage2 = [drinksObject largePicture];
    XCTAssertNotNil(largeImage2, @"Large image should exist.");
    largeImage2 = [drinksObject largePicture];
    XCTAssertNotNil(largeImage2, @"Large image should exist.");
    
    NSDictionary *fuelDictionary = @{ @"categoryId" : @3,
                                           @"categoryPictureFilename" : @"Fuel",
                                           @"categoryDescription" : @"Fuel" };
    MCCategoryPictureObject *fuelObject = [MCCategoryPictureObject objectFromDictionary:fuelDictionary];
    UIImage *smallImage3 = [fuelObject smallPicture];
    XCTAssertNotNil(smallImage3, @"Small image should exist.");
    smallImage3 = [fuelObject smallPicture];
    XCTAssertNotNil(smallImage3, @"Small image should exist.");
    UIImage *largeImage3 = [fuelObject largePicture];
    XCTAssertNotNil(largeImage3, @"Large image should exist.");
    largeImage3 = [fuelObject largePicture];
    XCTAssertNotNil(largeImage3, @"Large image should exist.");

    NSDictionary *groceriesDictionary = @{ @"categoryId" : @4,
                                 @"categoryPictureFilename" : @"Groceries",
                                 @"categoryDescription" : @"Groceries" };
    MCCategoryPictureObject *groceriesObject = [MCCategoryPictureObject objectFromDictionary:groceriesDictionary];
    UIImage *smallImage4 = [groceriesObject smallPicture];
    XCTAssertNotNil(smallImage4, @"Small image should exist.");
    smallImage4 = [groceriesObject smallPicture];
    XCTAssertNotNil(smallImage4, @"Small image should exist.");
    UIImage *largeImage4 = [groceriesObject largePicture];
    XCTAssertNotNil(largeImage4, @"Large image should exist.");
    largeImage4 = [groceriesObject largePicture];
    XCTAssertNotNil(largeImage4, @"Large image should exist.");
    
    NSDictionary *hotelDictionary = @{ @"categoryId" : @5,
                                        @"categoryPictureFilename" : @"Hotel",
                                        @"categoryDescription" : @"Hotel" };
    MCCategoryPictureObject *hotelObject = [MCCategoryPictureObject objectFromDictionary:hotelDictionary];
    UIImage *smallImage5 = [hotelObject smallPicture];
    XCTAssertNotNil(smallImage5, @"Small image should exist.");
    smallImage5 = [hotelObject smallPicture];
    XCTAssertNotNil(smallImage5, @"Small image should exist.");
    UIImage *largeImage5 = [hotelObject largePicture];
    XCTAssertNotNil(largeImage5, @"Large image should exist.");
    largeImage5 = [hotelObject largePicture];
    XCTAssertNotNil(largeImage5, @"Large image should exist.");
    
    NSDictionary *ticketsDictionary = @{ @"categoryId" : @6,
                                        @"categoryPictureFilename" : @"Drinks",
                                        @"categoryDescription" : @"Drinks" };
    MCCategoryPictureObject *ticketsObject = [MCCategoryPictureObject objectFromDictionary:ticketsDictionary];
    UIImage *smallImage6 = [ticketsObject smallPicture];
    XCTAssertNotNil(smallImage6, @"Small image should exist.");
    smallImage6 = [ticketsObject smallPicture];
    XCTAssertNotNil(smallImage6, @"Small image should exist.");
    UIImage *largeImage6 = [ticketsObject largePicture];
    XCTAssertNotNil(largeImage6, @"Large image should exist.");
    largeImage6 = [ticketsObject largePicture];
    XCTAssertNotNil(largeImage6, @"Large image should exist.");
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
