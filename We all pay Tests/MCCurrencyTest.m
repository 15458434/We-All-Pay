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
    
    [MCCurrency addAllAvailableCurrenciesToContext:_context];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testVerifyAddAllAvailableCurrenciesToContext
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCCurrency"];
    NSError *error;
    NSUInteger amountOfAvailableCurrencies = [_context countForFetchRequest:request error:&error];
    XCTAssertNil(error, @"Error counting availableCurrenciesInContext: %@", [error localizedDescription]);
    XCTAssertEqual(amountOfAvailableCurrencies, 158, @"Amount of available currencies should be 158.");
}

- (void)testGetCurrencySelectedInCurrentLocaleFromContext
{
    MCCurrency *selectedCurrency = [MCCurrency getCurrencySelectedInCurrentLocaleFromContext:_context];
    NSString *currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    XCTAssertTrue([[selectedCurrency code] isEqualToString:currencyCode], @"Wrong currency selected.");
}

- (void)testGetCurrencyWithCode
{
    MCCurrency *selectedCurrency = [MCCurrency getCurrencyWithCode:@"USD" FromContext:_context];
    XCTAssertTrue([[selectedCurrency code] isEqualToString:@"USD"], @"Wrong currency selected.");
}

@end
