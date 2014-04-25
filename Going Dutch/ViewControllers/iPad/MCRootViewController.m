//
//  MCRootViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 22-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCRootViewController.h"

@interface MCRootViewController ()

@end

@implementation MCRootViewController

#pragma mark - actions

- (IBAction)shareThisAppPressed:(id)sender
{
    NSArray *dataToShare = @[[NSString stringWithString:NSLocalizedString(@"I_FOUND_WE_ALL_PAY", @"Hi, I found this easy to use iPhone app to share a bill amongst friends. It is called We All Pay.")]];
    UIActivityViewController *shareMe = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    [self presentViewController:shareMe animated:YES completion:nil];
}


#pragma mark - Inherited From super

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [[self navigationController] setToolbarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
