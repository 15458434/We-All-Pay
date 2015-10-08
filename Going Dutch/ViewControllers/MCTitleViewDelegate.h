//
//  MCTitleViewDelegate.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;

@protocol MCTitleViewDelegate <NSObject>

- (UILabel *)mainTitleLabel;
- (UIPageControl *)pageIndicator;

@end
