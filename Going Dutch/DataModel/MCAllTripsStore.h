//
//  MCSharedBills.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCSharedBill;

@interface MCAllTripsStore : NSObject
{
    NSMutableArray *allTrips;
}

@property (nonatomic, strong) NSString *uniqueTripId;

+ (MCAllTripsStore *)sharedList;


- (void)addTrip:(MCSharedBill *)trip;
- (void)removeTrip:(MCSharedBill *)trip;
- (NSArray *)allTrips;

- (NSString *)itemArchivePath;
- (BOOL)saveChanges;

@end
