//
//  MCCurrencyTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCCurrency+addons.h"

#import "We_all_pay_Tests-Swift.h"

@interface MCCurrencyTest : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation MCCurrencyTest

- (void)setUp {
    [super setUp];
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
    XCTAssertTrue(persistentStore, @"Something went wrong opening the In Memory Store: %@", [error localizedDescription]);
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _context.persistentStoreCoordinator = persistentStoreCoordinator;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGenerateCurrencyFromSelectedLocaleForContext
{
    MCCurrency *selectedCurrency = [MCCurrency generateCurrencyFromSelectedLocaleForContext:_context];
    NSString *currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    XCTAssertTrue([[selectedCurrency code] isEqualToString:currencyCode], @"Wrong currency selected.");
    XCTAssertTrue(selectedCurrency.uniqueID, @"unique ID missing.");
    XCTAssertTrue(selectedCurrency.dateCreated, @"dateCreated is missing.");
    XCTAssertTrue(selectedCurrency.dateModified, @"dateModified is missing.");
}

- (void)testGetCurrencyWithCode
{
    MCCurrency *selectedCurrency = [MCCurrency currencyFrom:@"USD" fromContext:_context];
    XCTAssertTrue([[selectedCurrency code] isEqualToString:@"USD"], @"Wrong currency selected.");
}

@end
