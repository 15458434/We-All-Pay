//
//  MCPaymentPresenceTableViewCell_iPhone.m
//  We all pay
//
//  Created by Mark Cornelisse on 12/09/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresenceTableViewCell_iPhone.h"

#import "MCPaymentPresence+CoreDataProperties.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"

#import "We_all_pay-Swift.h"

static void * AverageOweFromPaymentContext = &AverageOweFromPaymentContext;

@interface MCPaymentPresenceTableViewCell_iPhone ()

@property (nonatomic, weak) MCPaymentPresence *model;

@end

@implementation MCPaymentPresenceTableViewCell_iPhone

- (IBAction)presenceIsSwitched:(UISwitch *)sender {
    self.model.isPersonPresent = @(self.isPresentSwitch.isOn);
    [self.model.payment recalculateAveragePeopleOweAndStore];
}

- (void)updatePaymentPresence:(MCPaymentPresence *)paymentPresence {
    if (self.model) {
        [self.model removeObserver:self forKeyPath:@"averageOweFromPayment" context:AverageOweFromPaymentContext];
    }
    self.model = paymentPresence;
    self.nameLabel.text = [self.model.person getFullName];
    self.personView.image = self.model.person.thumbnail;
    self.isPresentSwitch.on = self.model.isPersonPresent.boolValue;
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [self.model addObserver:self forKeyPath:@"averageOweFromPayment" options:options context:AverageOweFromPaymentContext];
}

#pragma mark - UITableViewCell

#pragma mark - UIView

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    if (self.model) {
        [self.model removeObserver:self forKeyPath:@"averageOweFromPayment" context:AverageOweFromPaymentContext];
    }
}

#pragma mark - NSKeyValueObservation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == AverageOweFromPaymentContext) {
#ifdef DEBUG
        NSLog(@"change: %@", change);
#endif
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting:
            {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[NSNumber class]]) {
                    NSNumber *averageOweFromPayment = (NSNumber *)new;
                    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:self.model.payment.currency.code];
                    NSNumber *averageOwe = @(-averageOweFromPayment.doubleValue);
                    self.owesLabel.text = [cf stringForObjectValue:averageOwe];
                } else {
                    self.owesLabel.text = @"";
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
