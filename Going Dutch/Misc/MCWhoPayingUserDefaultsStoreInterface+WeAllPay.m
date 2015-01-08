//
//  MCWhoPayingUserDefaultsStoreInterface+WeAllPay.m
//  We all pay
//
//  Created by Mark Cornelisse on 02/01/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

#import "MCWhoPayingUserDefaultsStoreInterface+WeAllPay.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"

@implementation MCWhoPayingUserDefaultsStoreInterface (WeAllPay)

+ (void)sendToUserDefaultsStoreInterface:(MCSharedBill *)tonightsBill
{
    // Get data in local variables.
    NSString *billID = tonightsBill.uniqueBillId;
    NSString *tripName = tonightsBill.tripName;
    MCPerson *nextPayer = [[tonightsBill fetchPeoplePresentOrderedByAmountPaid:YES] firstObject];
    NSString *nextPayerID = nextPayer.uniquePersonId;
    NSString *nextPayerName = [nextPayer getFullName];
    
    // Put it in a backgroundQueue
    dispatch_queue_t backgroundQueue = dispatch_queue_create("sendToWhoIsPayingNextQueue", NULL);
    dispatch_async(backgroundQueue, ^{
        MCWhoPayingUserDefaultsStoreInterface *storeInterface = [[MCWhoPayingUserDefaultsStoreInterface alloc] initWithTonightsBillUUID:billID withTripName:tripName andTheNextPayerID:nextPayerID withFullName:nextPayerName];
        [storeInterface storeToDefaults];
    });
}

+ (void)sendInvalidUserDefaultsIfTonightsBillIs:(MCSharedBill *)tonightsBill
{
    MCWhoPayingUserDefaultsStoreInterface *currentStoreInterfaceContents = [[MCWhoPayingUserDefaultsStoreInterface alloc] init];
    // if current tonightsBillId in the exchange store is tonightsBillID clear the contents otherwise leave them be.
    if ([tonightsBill.uniqueBillId isEqualToString:currentStoreInterfaceContents.tonightsBillUUID]) {
        [MCWhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:nil];
    }
}

@end
