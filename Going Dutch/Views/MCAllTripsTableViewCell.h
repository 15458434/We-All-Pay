//
//  MCAllTripsTableViewCell.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 18-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCAllTripsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tripLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCostLabel;
@property (weak, nonatomic) IBOutlet UILabel *peoplePresentLabel;
@property (weak, nonatomic) IBOutlet UILabel *extraLabel;

@end
