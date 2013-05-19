//
//  MCTextFieldAndLabelTitleView.h
//  We all pay
//
//  Created by Mark Cornelisse on 19-05-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCTextFieldAndLabelTitleView : UIControl
{
    
}

@property (weak, nonatomic) IBOutlet UITextField *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

- (id)delegate;
- (void)setDelegate:(id)delegate;

@end
