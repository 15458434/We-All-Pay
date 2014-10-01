//
//  MCPaymentTableViewCell_iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPaymentTableViewCell_iPad : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *namePayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *whatPaidLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyPaidLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pictureOfPayer;

//- (void)setCircularImage:(UIImage *)personImage;

@end
