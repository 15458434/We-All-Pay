//
//  MCReturnPaymentViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 07-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSharedBill;

@interface MCReturnPaymentViewController : UITableViewController
{
    MCSharedBill *tonightsBill;
    NSArray *paymentsAfterwards;
}

- (id)initWithBill:(MCSharedBill *)thisBill;

@property (nonatomic, strong) MCSharedBill *tonightsBill;

@end
