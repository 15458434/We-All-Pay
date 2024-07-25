//
//  MCCurrencyTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCCurrency+CoreDataProperties.h"
#import "CurrencyConverter/CurrencyConverter.h"

#import "We_all_pay_Tests-Swift.h"

@interface MCCurrencyTest : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) MCCurrencyModel *currencyModel;

@end

@implementation MCCurrencyTest

- (void)setUp {
    [super setUp];
    [WeAllPayStoreController.defaultStore openStoreOfType:NSInMemoryStoreType];
    _context = WeAllPayStoreController.defaultStore.viewContext;
    _currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGenerateCurrencyFromSelectedLocaleForContext
{
    NSError *error;
    MCCurrency *selectedCurrency = [_currencyModel generateCurrencyFromSelectedLocaleWithError:&error];
    XCTAssertNil(error, @"generateCurrencyFromSelectedLocaleWithError shouldn't result in an error");
    NSString *currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    XCTAssertTrue([[selectedCurrency code] isEqualToString:currencyCode], @"Wrong currency selected.");
    XCTAssertTrue(selectedCurrency.uniqueID, @"unique ID missing.");
    XCTAssertTrue(selectedCurrency.dateCreated, @"dateCreated is missing.");
    XCTAssertTrue(selectedCurrency.dateModified, @"dateModified is missing.");
}

- (void)testGetCurrencyWithCode
{
    MCCurrency *selectedCurrency = [_currencyModel currencyFromCurrencyCode:@"USD"];
    XCTAssertTrue([[selectedCurrency code] isEqualToString:@"USD"], @"Wrong currency selected.");
}

@end
