//
//  MCNotificationTableViewCell.m
//  We all pay
//
//  Created by Mark Cornelisse on 17/08/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCNotificationTableViewCell.h"
@import WeAllPayDesignableUI;
#import "MCNotificationUnreadIndicator.h"

#import "We_all_pay-Swift.h"

static void * isReadContext = &isReadContext;

@interface MCNotificationTableViewCell ()

@property (nonatomic, strong) MCNotificationsItem *model;

@property (nonatomic, weak) IBOutlet UIImageView *senderView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel;
@property (nonatomic, weak) IBOutlet MCNotificationUnreadIndicator *isReadIndicator;

@end

@implementation MCNotificationTableViewCell

- (void)updateModel:(MCNotificationsItem *)model {
    if (self.model) {
        [self removeObserver:self forKeyPath:@"model.isRead" context:isReadContext];
    }
    self.model = model;
    self.senderView.image = model.image;
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.subTitle;
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [self addObserver:self forKeyPath:@"model.isRead" options:options context:isReadContext];
    
}

#pragma mark - UITableViewCell

#pragma mark - UIView

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    if (self.model) {
        [self removeObserver:self forKeyPath:@"model.isRead" context:isReadContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == isReadContext) {
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
                    NSNumber *isRead = (NSNumber *)new;
                    self.isReadIndicator.show = !isRead.boolValue;
                } else {
                    self.isReadIndicator.show = NO;
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
