//
//  MCPaymentPresenceTableViewCell.m
//  We all pay
//
//  Created by Mark Cornelisse on 12-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresenceTableViewCell.h"

#import "MCPaymentPresence+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"

@implementation MCPaymentPresenceTableViewCell

#pragma mark - Actions.

- (IBAction)switchPresence:(id)sender
{
    [_thisCellsPaymentPresence setIsPersonPresent:@([sender isOn])];
}

#pragma mark - New in this class.

- (void)setCircularImage:(UIImage *)personImage
{
    __weak MCPaymentPresenceTableViewCell *weakSelf = self;
    
    dispatch_queue_t imageProcessQueue;
    imageProcessQueue = dispatch_queue_create("imageProcessQueue", NULL);
    
    dispatch_async(imageProcessQueue, ^{
        CGRect circularImageRect = CGRectMake(0, 0, 60, 60);
        UIImage *circularImage = [MCTools cutCircularImageFrom:personImage toDestinationRect:circularImageRect];
        dispatch_async(dispatch_get_main_queue(), ^{
            MCPaymentPresenceTableViewCell *strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf personView] setImage:circularImage];
                [strongSelf setNeedsDisplay];
            }
        });
    });
}

#pragma mark - Inherited from super.

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
