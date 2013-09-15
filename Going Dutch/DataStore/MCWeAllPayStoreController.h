//
//  MCWeAllPayStoreController.h
//  We all pay
//
//  Created by Mark Cornelisse on 08-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCPayment;
@class MCPerson;
@class MCSharedBill;

@interface MCWeAllPayStoreController : NSObject
{
    
}

@property (nonatomic, strong, readonly) UIManagedDocument *weAllPayStoreDocument;

+ (MCWeAllPayStoreController *)defaultStore;

- (void)saveStore;
- (void)closeDocument;

@end
