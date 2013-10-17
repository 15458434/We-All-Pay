//
//  MCEmailAddressTableViewCell.h
//  We all pay
//
//  Created by Mark Cornelisse on 17-10-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCEmailAddressTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *isDefaultLabel;

@end
