//
//  MCPaymentTableViewCell.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 21-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentTableViewCell.h"

@implementation MCPaymentTableViewCell

#pragma mark - New in this class

- (void)setCircularImage:(UIImage *)personImage
{
    __weak MCPaymentTableViewCell *weakSelf = self;
    
    __block UIImage *copyOfPersonImage = [personImage copy];
    dispatch_queue_t imageProcessQueue;
    imageProcessQueue = dispatch_queue_create("imageProcessQueue", NULL);
    
    dispatch_async(imageProcessQueue, ^{
        CGRect circularImageRect = CGRectMake(0, 0, 40, 40);
        UIImage *circularImage = [MCTools cutCircularImageFrom:copyOfPersonImage toDestinationRect:circularImageRect];
        dispatch_async(dispatch_get_main_queue(), ^{
            MCPaymentTableViewCell *strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf pictureOfPayer] setImage:circularImage];
                [strongSelf setNeedsDisplay];
            }
        });
    });
}

#pragma mark - Inherited from super

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
