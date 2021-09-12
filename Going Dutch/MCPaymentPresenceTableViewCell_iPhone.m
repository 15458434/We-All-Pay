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
#import "MCPerson+addons.h"

#import "We_all_pay-Swift.h"

static void * Context = &Context;

@interface MCPaymentPresenceTableViewCell_iPhone ()

@property (nonatomic, weak) MCPaymentPresence *model;

@end

@implementation MCPaymentPresenceTableViewCell_iPhone

- (IBAction)presenceIsSwitched:(UISwitch *)sender {
    self.model.isPersonPresent = @(self.isPresentSwitch.isOn);
    [self.model.payment recalculateAveragePeopleOweAndStore];
}

- (void)updatePaymentPresence:(MCPaymentPresence *)paymentPresence {
    self.model = paymentPresence;
    self.nameLabel.text = [self.model.person getFullName];
    self.personView.image = self.model.person.thumbnail;
    self.isPresentSwitch.on = self.model.isPersonPresent.boolValue;
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:self.model.payment.currency.code];
    NSNumber *averageOwe = @(-self.model.averageOweFromPayment.doubleValue);
    self.owesLabel.text = [cf stringForObjectValue:averageOwe];
}

#pragma mark - UITableViewCell

#pragma mark - UIView

#pragma mark - UIResponder

#pragma mark - NSObject

@end
