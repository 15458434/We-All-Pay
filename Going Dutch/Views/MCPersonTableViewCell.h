//
//  MCPersonTableViewCell.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 21-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPersonTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *fetchingExchangeRateIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *personImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalSpent;

- (void)setCircularImage:(UIImage *)personImage;

@end
