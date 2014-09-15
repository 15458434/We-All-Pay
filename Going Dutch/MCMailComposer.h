//
//  MCMailComposer.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCSharedBill+addons.h"

@interface MCMailComposer : NSObject
{
    
}

@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) NSArray *solution;
@property (nonatomic) BOOL isHTML;

- (NSArray *)getMailAddresses;
- (NSString *)getSubject;
- (NSString *)getMailBody;

@end
