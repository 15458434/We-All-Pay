//
//  MCSharedBillMainViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillMainViewController.h"

#import "MCSharedBill+addons.h"

@interface MCSharedBillMainViewController ()

@end

@implementation MCSharedBillMainViewController

#pragma mark - private functions

- (IBAction)toggleEdit:(id)sender
{
    [[self childViewControllers][0] toggleEdit:sender];
}


#pragma mark - Inherited from super

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
    [[self navigationController] setToolbarHidden:YES animated:YES];
    [MCTools setAdBannerIfNotPaid:YES forViewController:self];
    
    if (![self tonightsBill]) {
        _tonightsBill = [MCSharedBill addSharedBill];
        _currentView = MCSelectEditTripTableView;
    } else {
        _currentView = MCSelectSharedBillTableView;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPhone"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
