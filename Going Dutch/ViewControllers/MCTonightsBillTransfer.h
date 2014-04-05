//
//  MCTonightsBillTransfer.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCSharedBill;

@protocol MCTonightsBillPut <NSObject>

- (void)setTonightsBill:(MCSharedBill *)tonightsBill;

@end
@protocol MCTonightsBillGet <NSObject>

- (MCSharedBill *)tonightsBill;

@end

