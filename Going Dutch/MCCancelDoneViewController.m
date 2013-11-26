//
//  MCCancelDoneViewController.m
//  My bug and feature project
//
//  Created by Mark Cornelisse on 25-10-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCCancelDoneViewController.h"

@interface MCCancelDoneViewController ()

@end

@implementation MCCancelDoneViewController

@synthesize willShowButtons;
@synthesize switchInputField;

#pragma mark - Actions

- (void)mainCancelPressed:(id)selector
{
    NSLog(@"mainCancelPressed not implemented yet.");
}

- (void)mainDonePressed:(id)selector
{
    NSLog(@"mainDonePressed not implemented yet.");
}

#pragma mark - New in this class.

- (UITextField *)returnNextUITextField:(UITextField *)currentInput
{
    NSUInteger index = [listOfInputs indexOfObject:currentInput];
    index++;
    if (index < [listOfInputs count] && switchInputField) {
        return [listOfInputs objectAtIndex:index];
    } else {
        return nil;
    }
}

- (UITextField *)selectNextUITextField:(UITextField *)currentInput
{
    UITextField *nextInput = [self returnNextUITextField:currentInput];
    if (!nextInput) {
        [nextInput becomeFirstResponder];
    } else {
        NSLog(@"next input not available.");
    }
    return nextInput;
}

#pragma mark - Inherited From super.

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
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [MCTools setAdBannerIfNotPaid:NO forViewController:self];
    } else {
        [MCTools setAdBannerIfNotPaid:YES forViewController:self];
    }

    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (willShowButtons) {
        mainCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(mainCancelPressed:)];
        mainDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(mainDonePressed:)];
        [[self navigationItem] setLeftBarButtonItem:mainCancelButton];
        [[self navigationItem] setRightBarButtonItem:mainDoneButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
