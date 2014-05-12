//
//  MCPaymentPresenceTableViewCell.h
//  We all pay
//
//  Created by Mark Cornelisse on 12-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCPaymentPresence;

@interface MCPaymentPresenceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *theSwitch;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *personView;
@property (strong, nonatomic) MCPaymentPresence *thisCellsPaymentPresence;

- (IBAction)switchPresence:(id)sender;

- (void)setCircularImage:(UIImage *)personImage;

@end
