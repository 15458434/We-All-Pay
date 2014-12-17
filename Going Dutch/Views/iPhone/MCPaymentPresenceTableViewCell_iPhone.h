//
//  MCPaymentPresenceTableViewCell_iPhone.h
//  We all pay
//
//  Created by Mark Cornelisse on 15-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCPaymentPresence;

@interface MCPaymentPresenceTableViewCell_iPhone : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *personView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isPresentSwitch;
@property (weak, nonatomic) IBOutlet UILabel *owesLabel;
@property (strong, nonatomic) MCPaymentPresence *thisCellsPaymentPresence;

- (IBAction)presenceIsSwitched:(id)sender;

@end
