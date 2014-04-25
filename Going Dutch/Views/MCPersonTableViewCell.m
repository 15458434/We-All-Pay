//
//  MCPersonTableViewCell.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 21-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPersonTableViewCell.h"

@implementation MCPersonTableViewCell

#pragma mark - New in this class

- (void)setCircularImage:(UIImage *)personImage
{
    __weak MCPersonTableViewCell *weakSelf = self;
    
    __block UIImage *copyOfPersonImage = [personImage copy];
    dispatch_queue_t imageProcessQueue;
    imageProcessQueue = dispatch_queue_create("imageProcessQueue", NULL);
    
    dispatch_async(imageProcessQueue, ^{
        CGRect circularImageRect = CGRectMake(0, 0, 40, 40);
        UIImage *circularImage = [MCTools cutCircularImageFrom:copyOfPersonImage toDestinationRect:circularImageRect];
        dispatch_async(dispatch_get_main_queue(), ^{
            MCPersonTableViewCell *strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf personImage] setImage:circularImage];
                [strongSelf setNeedsDisplay];
            }
        });
    });
}

#pragma mark - Inherited From Super

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
