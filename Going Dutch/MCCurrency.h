//
//  MCCurrency.h
//  We all pay
//
//  Created by Mark Cornelisse on 22/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCSharedBill;

@interface MCCurrency : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * symbol;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSNumber * isStillValid;
@property (nonatomic, retain) NSSet *sharedBill;
@end

@interface MCCurrency (CoreDataGeneratedAccessors)

- (void)addSharedBillObject:(MCSharedBill *)value;
- (void)removeSharedBillObject:(MCSharedBill *)value;
- (void)addSharedBill:(NSSet *)values;
- (void)removeSharedBill:(NSSet *)values;

@end
