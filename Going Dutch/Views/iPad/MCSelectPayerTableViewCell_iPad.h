//
//  MCSelectPayerTableViewCell_iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 07-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCSelectPayerTableViewCell_iPad : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;

- (void)setCircularImage:(UIImage *)personImage;

@end
