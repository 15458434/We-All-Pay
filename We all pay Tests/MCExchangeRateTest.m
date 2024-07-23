//
//  MCExchangeRateTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCExchangeRate+CoreDataProperties.h"

#import "We_all_pay_Tests-Swift.h"

@interface MCExchangeRateTest : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation MCExchangeRateTest

- (void)setUp {
    [super setUp];
    [WeAllPayStoreController.defaultStore openStoreOfType:NSInMemoryStoreType];
    _context = WeAllPayStoreController.defaultStore.viewContext;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInsert
{
    MCExchangeRate *newlyInsertedExchangeRate = [[MCExchangeRate alloc] initWithContext:_context];
    XCTAssertNotNil([newlyInsertedExchangeRate uniqueID], @"unique ID not present.");
    XCTAssertNotNil([newlyInsertedExchangeRate dateCreated], @"dateCreated not present.");
    XCTAssertNotNil([newlyInsertedExchangeRate dateModified], @"dateModified not present.");
    XCTAssert([[newlyInsertedExchangeRate status] shortValue] == MCExchangeRateStatusValid, @"shortValue should be valid after creating");
}

@end
