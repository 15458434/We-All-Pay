//
//  MCPaymentPresenceTableViewCell_iPhone.m
//  We all pay
//
//  Created by Mark Cornelisse on 12/09/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresenceTableViewCell_iPhone.h"
#import "MCPaymentPresence+addons.h"
#import "MCPayment+addons.h"

@interface MCPaymentPresenceTableViewCell_iPhone ()


@end

@implementation MCPaymentPresenceTableViewCell_iPhone

- (void)presenceIsSwitched:(UISwitch *)sender {
    self.thisCellsPaymentPresence.isPersonPresent = @(self.isPresentSwitch.isOn);
    [self.thisCellsPaymentPresence.payment recalculateAveragePeopleOweAndStore];
}

#pragma mark - UITableViewCell

#pragma mark - UIView

#pragma mark - UIResponder

#pragma mark - NSObject

@end
