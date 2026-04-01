//
//  MCPaymentPresenceTableViewCell_iPhone.m
//  We all pay
//
//  Created by Mark Cornelisse on 12/09/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresenceTableViewCell_iPhone.h"

#import "We_all_pay-Swift.h"

static void * AverageOweFromPaymentContext = &AverageOweFromPaymentContext;

@interface MCPaymentPresenceTableViewCell_iPhone ()

@property (nonatomic, weak) MCPaymentModel *model;
@property (nonatomic, weak) MCPaymentPresence *paymentPresence;

@end

@implementation MCPaymentPresenceTableViewCell_iPhone

- (IBAction)presenceIsSwitched:(UISwitch *)sender {
    [_model updatePaymentPresence:_paymentPresence toIsPresent:self.isPresentSwitch.isOn];
}

- (void)updateModel:(MCPaymentModel *)model andPaymentPresence:(MCPaymentPresence *)paymentPresence {
    _model = model;
    if (self.paymentPresence) {
        [self.paymentPresence removeObserver:self forKeyPath:@"averageOweFromPayment" context:AverageOweFromPaymentContext];
    }
    self.paymentPresence = paymentPresence;
    self.nameLabel.text = self.paymentPresence.person.fullName;
    self.personView.image = self.paymentPresence.person.thumbnail;
    self.isPresentSwitch.on = self.paymentPresence.isPersonPresent.boolValue;
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [self.paymentPresence addObserver:self forKeyPath:@"averageOweFromPayment" options:options context:AverageOweFromPaymentContext];
}

#pragma mark - UITableViewCell

#pragma mark - UIView

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    if (self.paymentPresence) {
        [self.paymentPresence removeObserver:self forKeyPath:@"averageOweFromPayment" context:AverageOweFromPaymentContext];
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
                    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:self.paymentPresence.payment.currency.code];
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
