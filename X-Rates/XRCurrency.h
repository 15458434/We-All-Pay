//
//  XRCurrency.h
//  We all pay
//
//  Created by Mark Cornelisse on 18/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

__deprecated
@interface XRCurrency : NSManagedObject

@property (nonatomic, retain) NSNumber * isStillValid;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * symbol;
@property (nonatomic, retain) NSString * uniqueID;

@end
