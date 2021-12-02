//
//  MCPurchaseTableViewCell.m
//  We all pay
//
//  Created by Mark Cornelisse on 17/09/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCPurchaseTableViewCell.h"

#import "We_all_pay-Swift.h"

static void * ProProductContext = &ProProductContext;

@interface MCPurchaseTableViewCell ()

@property (nonatomic, weak) MCStoreInterface *model;

@end

@implementation MCPurchaseTableViewCell

- (void)updateStoreInterface:(MCStoreInterface *)model {
    if (self.model) {
        [self.model removeObserver:self forKeyPath:@"proProduct"];
    }
    
    self.model = model;
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [self.model addObserver:self forKeyPath:@"proProduct" options:options context:ProProductContext];
}

#pragma mark - UITableViewCell

#pragma mark - UIView

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    if (self.model) {
        [self.model removeObserver:self forKeyPath:@"proProduct"];
    }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == ProProductContext) {
        self.purchaseDescriptionLabel.text = NSLocalizedStringWithDefaultValue(@"info_view_cell_buy_ad_free", nil, NSBundle.mainBundle, @"Buy ad free version", @"Button in the info view that will make the ad free in app purchase for the user");
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting:
            {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[SKProduct class]]) {
                    SKProduct *product = (SKProduct *)new;
                    self.priceLabel.text = product.localizedPriceString;
                } else {
                    self.priceLabel.text = @"";
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
