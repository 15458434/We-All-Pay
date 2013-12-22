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

#pragma mark - new in this class

- (void)setViewControllersFromStoryboard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
    MCSharedBillTableViewController *sharedBillView = [storyboard instantiateViewControllerWithIdentifier:@"MCSharedBillTableViewController"];
    [sharedBillView setTonightsBill:tonightsBill];
    MCEditTripViewController *editTripView = [storyboard instantiateViewControllerWithIdentifier:@"MCEditTripViewController"];
    [editTripView setTonightsBill:tonightsBill];
    NSArray *views = [NSArray arrayWithObjects:sharedBillView, nil];
    [self setViewControllers:views direction:UIPageViewControllerNavigationOrientationHorizontal animated:YES completion:nil];
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
    
    
    if ([tonightsBill tripName]) {
        [titleLabel setText:[tonightsBill tripName]];
    } else {
        [titleLabel setText:@"..."];
    }
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
    if ([pageViewIndicator currentPage] == 1) {
        newPageNumber = 0;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
        MCSharedBillTableViewController *sharedBillView = [storyboard instantiateViewControllerWithIdentifier:@"MCSharedBillTableViewController"];
        [sharedBillView setTonightsBill:tonightsBill];
        [sharedBillView setDelegate:self];
        return nil;
    } else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([pageViewIndicator currentPage] == 0) {
        newPageNumber = 1;
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
    if (completed) {
        [pageViewIndicator setCurrentPage:newPageNumber];
    }
}

@end
