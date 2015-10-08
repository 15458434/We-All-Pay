//
//  MCCurrencyTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCWeAllPayStoreController.h"
#import "MCCurrency+addons.h"

@interface MCCurrencyTest : XCTestCase
{
    MCWeAllPayStoreController *_mainController;
    NSManagedObjectContext *_context;
}

@end

@implementation MCCurrencyTest

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

- (void)testGetCurrencySelectedInCurrentLocaleFromContext
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
