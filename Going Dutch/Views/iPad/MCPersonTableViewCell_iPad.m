//
//  MCPersonTableViewCell_iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPersonTableViewCell_iPad.h"

@implementation MCPersonTableViewCell_iPad

#pragma mark - New in this class.

//- (void)setCircularImage:(UIImage *)personImage
//{
//    __weak MCPersonTableViewCell_iPad *weakSelf = self;
//    
//    dispatch_queue_t imageProcessQueue;
//    imageProcessQueue = dispatch_queue_create("imageProcessQueue", NULL);
//    
//    dispatch_async(imageProcessQueue, ^{
//        CGRect circularImageRect = CGRectMake(0, 0, 80, 80);
//        UIImage *circularImage = [MCTools cutCircularImageFrom:personImage toDestinationRect:circularImageRect];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            MCPersonTableViewCell_iPad *strongSelf = weakSelf;
//            if (strongSelf) {
//                [[strongSelf personImage] setImage:circularImage];
//                [strongSelf setNeedsDisplay];
//            }
//        });
//    });
//}

#pragma mark - Inherited From Super

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
