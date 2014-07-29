//
//  MCSelectCurrencyViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 28/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSelectCurrencyViewController.h"
#import "MCPayment+addons.h"

#import "MCDismissMeBlockProtocol.h"

@interface MCSelectCurrencyViewController ()

@end

@implementation MCSelectCurrencyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"insertCurrencyList"]) {
        id destination = [segue destinationViewController];
        __weak __typeof(self) weakSelf = self;
        if ([destination conformsToProtocol:@protocol(MCThisPaymentProtocol)]) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                [destination setThisPayment:_thisPayment];
            }
        }
        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
            [destination setDismissMe:^{
                [[self navigationController] popViewControllerAnimated:YES];
            }];
        }
        
    }
}

@end
