//
//  MCPurchaseTableViewCell.h
//  We all pay
//
//  Created by Mark Cornelisse on 17/09/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface MCPurchaseTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *purchaseDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;

@end

NS_ASSUME_NONNULL_END
