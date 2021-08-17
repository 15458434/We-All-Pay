//
//  MCNotificationTableViewCell.h
//  We all pay
//
//  Created by Mark Cornelisse on 17/08/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

@import UIKit;

@class MCNotificationsItem;

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
NS_SWIFT_NAME(NotificationTableViewCell)
@interface MCNotificationTableViewCell : UITableViewCell

- (void)updateModel:(MCNotificationsItem *)model NS_SWIFT_NAME(update(model:));

@end

NS_ASSUME_NONNULL_END
