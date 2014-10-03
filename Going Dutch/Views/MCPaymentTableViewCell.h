//
//  MCPaymentTableViewCell.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 21-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPaymentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *namePayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *whatPaidLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyPaidLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pictureOfPayer;

//- (void)setCircularImage:(UIImage *)personImage;

@end
