//
//  MCNotificationsCountTableViewCell.m
//  We all pay
//
//  Created by Mark Cornelisse on 17/08/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCNotificationsCountTableViewCell.h"

#import "We_all_pay-Swift.h"

static void * messageCountContext = &messageCountContext;

@interface MCNotificationsCountTableViewCell ()

@property (nonatomic, strong) MCNotificationsInfoModel *model;

@property (nonatomic, weak) UILabel *leftLabel;
@property (nonatomic, weak) MCUnreadNotificationsCountView *countView;

@end

@implementation MCNotificationsCountTableViewCell

- (void)updateModel:(MCNotificationsInfoModel *)model {
    if (self.model) {
        [self removeObserver:self forKeyPath:@"model.messageCount" context:messageCountContext];
    }
    self.model = model;
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [self addObserver:self forKeyPath:@"model.messageCount" options:options context:messageCountContext];
}

#pragma mark - UITableViewCell

#pragma mark - UIView

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    if (self.model) {
        [self removeObserver:self forKeyPath:@"model.messageCount" context:messageCountContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == messageCountContext) {
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
                    NSNumber *messageCount = (NSNumber *)new;
                    if (messageCount.integerValue  > 0 ) {
                        self.countView.hidden = false;
                        self.countView.count = messageCount.integerValue;
                    } else {
                        self.countView.hidden = YES;
                    }
                } else {
                    self.countView.hidden = YES;
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
