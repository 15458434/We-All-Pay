//
//  MCAllTripsTableViewCell_iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCAllTripsTableViewCell_iPad : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tripLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCostLabel;
@property (weak, nonatomic) IBOutlet UILabel *peoplePresentLabel;
@property (weak, nonatomic) IBOutlet UILabel *extraLabel;

@end
