//
//  XRCurrencyStoreControllerTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 20/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "XRCurrencyStoreController.h"
#import "XRCurrency.h"

@interface XRCurrencyStoreControllerTest : XCTestCase

@property (nonatomic, strong) XRCurrencyStoreController *currencyStore;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation XRCurrencyStoreControllerTest

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
    
    // Check for currencies if delete all an repopulate
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XRCurrency"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSError *countError;
    NSUInteger amountOfCurrencies = [_context countForFetchRequest:request error:&countError];
    XCTAssertNil(countError, @"%@", countError);
    if (amountOfCurrencies > 0) {
        NSError *fetchError;
        NSArray *allCurrencies = [_context executeFetchRequest:request error:&fetchError];
        XCTAssertNil(fetchError, @"%@", fetchError);
        for (NSManagedObject *currency in allCurrencies) {
            [_context deleteObject:currency];
        }
    }
    [XRCurrencyStoreController populateCurrencyDataBaseIfEmptyForContext:_context];
    amountOfCurrencies = [_context countForFetchRequest:request error:&countError];
    XCTAssertNil(countError, @"%@", countError);
    XCTAssert(amountOfCurrencies == 158, @"Amount of currencies should be 158.");
    [XRCurrencyStoreController populateCurrencyDataBaseIfEmptyForContext:_context];
    amountOfCurrencies = [_context countForFetchRequest:request error:&countError];
    XCTAssertNil(countError, @"%@", countError);
    XCTAssert(amountOfCurrencies == 158, @"Amount of currencies should be 158.");
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testFetchCurrencyWithCodeForContext
{
    XRCurrency *currency = [[XRCurrencyStoreController sharedStore] fetchCurrencyWithCode:@"USD" inContext:_context];
    XCTAssertTrue([[currency code] isEqualToString:@"USD"], @"Wrong currency fetched.");
}


@end
