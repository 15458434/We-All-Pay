//
//  MCWeAllPayStoreController.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCWeAllPayStoreController.h"
#import "MCTools.h"

@implementation MCWeAllPayStoreController

@synthesize weAllPayStoreDocument;

#pragma mark - New in this class

+ (MCWeAllPayStoreController *)sharedStore
{
    static MCWeAllPayStoreController *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

#pragma mark - Inherited from super class

- (id)init
{
    self = [super init];
    
    static BOOL stillNeedsInit = 1;
    
    if (self && stillNeedsInit) {
        weAllPayStoreDocument = [[UIManagedDocument alloc] initWithFileURL:[MCTools documentPathAsURLTo:@"WeAllPayStore"]];
        stillNeedsInit = 0;
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

@end
