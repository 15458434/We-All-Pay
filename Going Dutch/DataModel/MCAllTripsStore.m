//
//  MCSharedBills.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCAllTripsStore.h"
#import "MCSharedBill.h"
#import "MCPerson.h"
#import "MCPeople.h"

@implementation MCAllTripsStore

@synthesize uniqueTripId;

#pragma mark - New in this class

+ (MCAllTripsStore *)sharedList
{
    static MCAllTripsStore *theList = nil;
    // if sharedStore doesn't already exist, created it.
    if (!theList) {
        theList = [[super allocWithZone:nil] init];
    }
    
    return theList;
}

- (void)addTrip:(MCSharedBill *)trip
{
    [allTrips addObject:trip];
}

- (void)removeTrip:(MCSharedBill *)trip
{
    for (MCPerson *p in [[trip people] allPeople]) {
        [p removeThumbnail];
    }
    [allTrips removeObject:trip];
}

- (NSArray *)allTrips
{
    return allTrips;
}

-(NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"alltrip.archive"];
}

-(BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:allTrips toFile:path];
}

#pragma mark - Inherited from super.

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedList];
}

- (id)init
{
    self = [super init];
    if (self) {
        allTrips = [NSKeyedUnarchiver unarchiveObjectWithFile:[self itemArchivePath]];
        
        if (!allTrips) {
            allTrips = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

@end
