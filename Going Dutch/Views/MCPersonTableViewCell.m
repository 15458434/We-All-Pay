//
//  MCPersonTableViewCell.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 21-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPersonTableViewCell.h"

@implementation MCPersonTableViewCell

@synthesize nameLabel;
@synthesize personImage;
@synthesize emailLabel;

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
