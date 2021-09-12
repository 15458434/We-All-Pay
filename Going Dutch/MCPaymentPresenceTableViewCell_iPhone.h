//
//  MCPaymentPresenceTableViewCell_iPhone.h
//  We all pay
//
//  Created by Mark Cornelisse on 12/09/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

@import UIKit;

@class MCPaymentPresence;

NS_ASSUME_NONNULL_BEGIN

@interface MCPaymentPresenceTableViewCell_iPhone : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *personView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UISwitch *isPresentSwitch;
@property (nonatomic, weak) UILabel *owesLabel;

@property (nonatomic, strong) MCPaymentPresence *thisCellsPaymentPresence;

- (IBAction)presenceIsSwitched:(UISwitch *)sender;

@end

NS_ASSUME_NONNULL_END
