//
//  MCPaymentPresenceTableViewCell_iPhone.m
//  We all pay
//
//  Created by Mark Cornelisse on 15-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresenceTableViewCell_iPhone.h"

#import "MCPaymentPresence+addons.h"
#import "MCPayment+addons.h"

@implementation MCPaymentPresenceTableViewCell_iPhone

#pragma mark - Actions

- (IBAction)presenceIsSwitched:(id)sender
{
    [_thisCellsPaymentPresence setIsPersonPresent:@([_isPresentSwitch isOn])];
    [[_thisCellsPaymentPresence payment] recalculateAveragePeopleOweAndStore];
}

#pragma mark - New in this class

#pragma mark - Inherited from super

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
