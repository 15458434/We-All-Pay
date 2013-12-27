//
//  MCPageViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 22-12-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillPageViewController.h"

#import "MCSharedBillTableViewController.h"
#import "MCEditTripViewController.h"

#import "MCSharedBill.h"

#import "MCWeAllPayStoreController.h"

@interface MCSharedBillPageViewController ()

@end

@implementation MCSharedBillPageViewController

@synthesize tonightsBill;

#pragma mark - actions

- (IBAction)toggleEdit:(id)sender
{
    static BOOL isEditing = NO;
    if (isEditing) {
        [[[[self viewControllers] objectAtIndex:0] tableView] setEditing:NO animated:YES];
        isEditing = NO;
    } else {
        [[[[self viewControllers] objectAtIndex:0] tableView] setEditing:YES animated:YES];
        isEditing = YES;
    }
}

#pragma mark - new in this class

- (void)setViewControllersFromStoryboard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
    MCSharedBillTableViewController *sharedBillView = [storyboard instantiateViewControllerWithIdentifier:@"MCSharedBillTableViewController"];
    [sharedBillView setTonightsBill:tonightsBill];
    MCEditTripViewController *editTripView = [storyboard instantiateViewControllerWithIdentifier:@"MCEditTripViewController"];
    [editTripView setTonightsBill:tonightsBill];
    NSArray *views = [NSArray arrayWithObjects:sharedBillView, nil];
    [self setViewControllers:views direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self setDelegate:self];
    [self setDataSource:self];
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
    
    [self setViewControllersFromStoryboard];
    
    [titleLabel setText:@"Payments"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MCTonightsBillTitleDelegate

@synthesize titleLabel;

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([[[self viewControllers] objectAtIndex:0] isKindOfClass:[MCEditTripViewController class]]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
        MCSharedBillTableViewController *sharedBillView = [storyboard instantiateViewControllerWithIdentifier:@"MCSharedBillTableViewController"];
        [sharedBillView setTonightsBill:tonightsBill];
        [sharedBillView setDelegate:self];
        return sharedBillView;
    } else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([[[self viewControllers] objectAtIndex:0] isKindOfClass:[MCSharedBillTableViewController class]]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
        MCEditTripViewController *editTripView = [storyboard instantiateViewControllerWithIdentifier:@"MCEditTripViewController"];
        [editTripView setTonightsBill:tonightsBill];
        [editTripView setDelegate:self];
        return editTripView;
    } else {
        return nil;
    }
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed && finished) {
        if ([[[self viewControllers] objectAtIndex:0] isKindOfClass:[MCEditTripViewController class]]) {
            [pageViewIndicator setCurrentPage:1];
            [titleLabel setText:@"People present"];
        } else if ([[[self viewControllers] objectAtIndex:0] isKindOfClass:[MCSharedBillTableViewController class]]) {
            [pageViewIndicator setCurrentPage:0];
            [titleLabel setText:@"Payments"];
        }
    }
}

@end
