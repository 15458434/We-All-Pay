//
//  MCSharedBill+TestHelper.h
//  We all pay Tests
//
//  Created by Mark Cornelisse on 04/08/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSharedBill (TestHelper)

- (BOOL)isPresentWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmailAddress:(NSString *)emailAddress;

@end

NS_ASSUME_NONNULL_END
