//
//  MCExchangeRateTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCWeAllPayStoreController.h"

#import "MCExchangeRate+addons.h"

@interface MCExchangeRateTest : XCTestCase
{
    MCWeAllPayStoreController *_mainController;
    NSManagedObjectContext *_context;
}

@end

@implementation MCExchangeRateTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
    XCTAssertTrue(persistentStore, @"Something went wrong opening the In Memory Store: %@", [error localizedDescription]);
    _context = [[NSManagedObjectContext alloc] init];
    [_context setPersistentStoreCoordinator:persistentStoreCoordinator];

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInsert
{
    MCExchangeRate *newlyInsertedExchangeRate = [MCExchangeRate addExchangeRateForContext:_context];
    XCTAssertNotNil([newlyInsertedExchangeRate uniqueID], @"unique ID not present.");
    XCTAssertNotNil([newlyInsertedExchangeRate dateCreated], @"dateCreated not present.");
    XCTAssertNotNil([newlyInsertedExchangeRate dateModified], @"dateModified not present.");
    XCTAssert([[newlyInsertedExchangeRate status] shortValue] == MCExchangeRateStatusValid, @"shortValue should be valid after creating");
}

@end
