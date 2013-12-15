//
//  MCTripInfoViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 15-12-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSharedBill;

@interface MCTripInfoViewController : UIViewController <UITextFieldDelegate>
{
    __weak IBOutlet UITextField *tripNameField;
}

@property (nonatomic, strong) MCSharedBill *tonightsBill;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

@end
