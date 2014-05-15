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
#import "MCReturnPaymentViewController.h"

#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"

#import "MCWeAllPayStoreController.h"
#import "MCReturnPayment.h"

#import "MCTitleViewDelegate.h"
#import "MCCurrentViewDelegate.h"

@interface MCSharedBillPageViewController ()

@end

@implementation MCSharedBillPageViewController

#pragma mark - actions

- (IBAction)toggleEdit:(id)sender
{
    if ([[[self viewControllers][0] tableView] isEditing]) {
        [[[self viewControllers][0] tableView] setEditing:NO animated:YES];
    } else {
        [[[self viewControllers][0] tableView] setEditing:YES animated:YES];
    }
}

- (IBAction)solveBill:(id)sender
{
    
}

- (void)editBillData:(id)sender
{
    //[self performSegueWithIdentifier:@"openTripInfo" sender:self];
    [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    if ([[self viewControllers][0] isKindOfClass:[MCSharedBillTableViewController class]]) {
        
    }
}

#pragma mark - new in this class

- (void)setSharedBillViewControllerFromStoryboard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
    sharedBillTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MCSharedBillTableViewController"];
    [sharedBillTableViewController setTonightsBill:[self tonightsBill]];
    [sharedBillTableViewController setMailDelegate:self];
    [[self pageViewIndicator] setCurrentPage:1];
    [[self titleLabel] setText:NSLocalizedString(@"PAYMENTS_PAGEVIEWCONTROLLER", @"Payments")];
    NSArray *views = @[sharedBillTableViewController];
    [self setViewControllers:views direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    [self setDelegate:self];
    [self setDataSource:self];
}

- (void)setEditTripViewControllerFromStoryboard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
    editTripTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MCEditTripViewController"];
    [editTripTableViewController setTonightsBill:[self tonightsBill]];
    NSArray *views = @[editTripTableViewController];
    [[self pageViewIndicator] setCurrentPage:0];
    [[self titleLabel] setText:NSLocalizedString(@"PEOPLE_PRESENT_PAGEVIEWCONTROLLER", @"People present")];
    [self setViewControllers:views direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self setDelegate:self];
    [self setDataSource:self];
}

- (void)openMailView:(id)sender
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController setMailComposeDelegate:sender];
    [mailViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    [mailViewController setModalPresentationStyle:UIModalPresentationFormSheet];
//    [[mailViewController navigationBar] setBarStyle:UIBarStyleBlack];
//    [[[mailViewController navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    [[mailViewController viewControllers][0] setEdgesForExtendedLayout:UIRectEdgeNone];
    NSArray *sda = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *allPeople = [[[self tonightsBill] peoplePresent] sortedArrayUsingDescriptors:sda];
    // Create a list of all email addresses
    NSMutableArray *listOfMailAddresses = [[NSMutableArray alloc] init];
    for (MCPerson *p in allPeople) {
        if ([p defaultEmailAddress]) {
            [listOfMailAddresses addObject:[p defaultEmailAddress]];
        }
    }
    // Set the mail header.
    [mailViewController setToRecipients:listOfMailAddresses];
    NSString *subject1 = NSLocalizedString(@"EMAIL_SUBJECT_PART_ONE", @"Bill overview of our trip to %@");
    [mailViewController setSubject:[[NSString alloc] initWithFormat:@"%@ %@.", subject1, [[self tonightsBill] tripName]]];
    
    // Generate the text for the email.
    NSMutableString *mailBody = [[NSMutableString alloc] init];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [mailBody appendFormat:@"%@ %@,\n", NSLocalizedString(@"EMAIL_DEAR", @"Just Dear as in \"Dear Mark\""), [[self tonightsBill] stringOfApproxPeoplePresent]];
    [mailBody appendFormat:@"\n"];
    NSString *intro1 = NSLocalizedString(@"EMAIL_INTRO_PART_ONE", @"From a total of \"$ 20,45\", which was spend on our last trip to \"Movies\". We all have to pay an equal share of \"$6,82\".");
    NSString *intro2 = NSLocalizedString(@"EMAIL_INTRO_PART_TWO", @"From a total of \"$ 20,45\", which was spend on our last trip to \"Movies\". We all have to pay an equal share of \"$6,82\".");
    NSString *intro3 = NSLocalizedString(@"EMAIL_INTRO_PART_THREE", @"From a total of \"$ 20,45\", which was spend on our last trip to \"Movies\". We all have to pay an equal share of \"$6,82\".");
    [mailBody appendFormat:@"%@ %@, %@ %@. %@ %@.\n", intro1, [nf stringFromNumber:[[self tonightsBill] totalSumOfMoneyOfThisSharedBill]], intro2,[[self tonightsBill] tripName], intro3, [nf stringFromNumber:[[self tonightsBill] amountPeopleShouldHavePaid]]];
    [mailBody appendFormat:@"\n"];
    if ([[self tonightsBill] totalAmountOfPeopleWhoHavePaid] == 0) {
        [mailBody appendFormat:@"%@\n", NSLocalizedString(@"EMAIL_NOBODY_HAS_PAID", @"The message that nobody has paid so far")];
    } else if ([[self tonightsBill] totalAmountOfPeopleWhoHavePaid] == 1) {
        [mailBody appendFormat:@"%@:\n", NSLocalizedString(@"EMAIL_ONE_PERSON_HAS_PAID", @"The person who has payed")];
    } else {
        [mailBody appendFormat:@"%@:\n", NSLocalizedString(@"EMAIL_MULTIPLE_PEOPLE_HAVE_PAID", @"The people who have paid are")];
    }
    NSArray * allPayments = [[[self tonightsBill] payments] sortedArrayUsingDescriptors:sda];
    for (MCPayment *p in allPayments) {
        NSString *whoHasPaid1 = NSLocalizedString(@"EMAIL_WHO_HAS_PAID_ONE", @"Part one of the sentence: Mark has paid $24 for beer.");
        NSString *whoHasPaid2 = NSLocalizedString(@"EMAIL_WHO_HAS_PAID_TWO", @"Part two of the sentence: Mark has paid $24 for beer.");
        [mailBody appendFormat:@"%@ %@ %@ %@ %@.\n", [[p payingPerson] getName], whoHasPaid1, [nf stringFromNumber:[p money]], whoHasPaid2, [p descriptionOfPayment]];
    }
    [mailBody appendFormat:@"\n"];
    NSString *average1 = NSLocalizedString(@"EMAIL_AVERAGE_SENTENCES_ONE", @"Part one of: To have everybody pay the average of $7.00, I suggest the following solution:");
    NSString *average2 = NSLocalizedString(@"EMAIL_AVERAGE_SENTENCES_TWO", @"Part two of: To have everybody pay the average of $7.00, I suggest the following solution:");
    [mailBody appendFormat:@"%@ %@%@:\n", average1, [nf stringFromNumber:[[self tonightsBill] amountPeopleShouldHavePaid]], average2];
    for (MCReturnPayment *rp in [[self tonightsBill] solveWhoHasToPayWhoFromThisBill]) {
        [mailBody appendFormat:@"%@\n", [rp stringForMail]];
    }
    [mailBody appendFormat:@"\n"];
    [mailBody appendFormat:@"%@.", NSLocalizedString(@"EMAIL_FINAL SENTENCE", @"If you have any remarks please let me know.")];
    [mailViewController setMessageBody:mailBody isHTML:NO];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [MCTools setAdBannerIfNotPaid:NO forViewController:[mailViewController viewControllers][0]];
    } else {
        //[MCTools setAdBannerIfNotPaid:YES forViewController:[[mailViewController viewControllers] objectAtIndex:0]];
    }
    if (sender!=self) {
        [sender presentViewController:mailViewController animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [mailViewController setNeedsStatusBarAppearanceUpdate];
        }];
    } else {
        [[self navigationController] presentViewController:mailViewController animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [mailViewController setNeedsStatusBarAppearanceUpdate];
        }];
    }
}

- (void)shareBill:(id)sender
{
    if ([[self tonightsBill] doesEveryoneHaveAnEmailAddress]) {
        [self openMailView:sender];
    } else {
        NSLog(@"Not everyone has an email address");
        UIAlertView *mailAddressesMissing = [[UIAlertView alloc] initWithTitle:@"Unable to send email to all people."
                                                                       message:@"Reason: Not all people have a mail address."
                                                                      delegate:self
                                                             cancelButtonTitle:@"Cancel"
                                                             otherButtonTitles:@"Send anyway", nil];
        [mailAddressesMissing setDelegate:self];
        [mailAddressesMissing show];
    }
}

- (void)sendMail:(id)sender
{
    
}

- (UIPageControl *)pageViewIndicator
{
    id destination = [self parentViewController];
    if ([destination conformsToProtocol:@protocol(MCTitleViewDelegate)]) {
        return [destination pageIndicator];
    } else {
        NSLog(@"Something is broken in the protocol.");
        return nil;
    }
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
    
    [[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id destination = [self parentViewController];
    BOOL conformsGet = [destination conformsToProtocol:@protocol(MCTonightsBillGet)];
    NSParameterAssert(conformsGet);
    BOOL conformsCurrentView = [destination conformsToProtocol:@protocol(MCCurrentViewDelegate)];
    NSParameterAssert(conformsCurrentView);
    
    if ([destination currentView] == MCSelectSharedBillTableView) {
        [self setSharedBillViewControllerFromStoryboard];
    } else {
        [self setEditTripViewControllerFromStoryboard];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - MCTonightsBillTitleDelegate

- (UILabel *)titleLabel
{
    id destination = [self parentViewController];
    if ([destination conformsToProtocol:@protocol(MCTitleViewDelegate)]) {
        return [destination mainTitleLabel];
    } else {
        NSLog(@"mainTitle not askable.");
        return nil;
    }
}

- (void)setTitleLabel:(UILabel *)titleLabel
{
    
}

#pragma mark - MCTonightsBillGet

- (MCSharedBill *)tonightsBill
{
    id destination = [self parentViewController];
    if ([destination conformsToProtocol:@protocol(MCTonightsBillGet)]) {
        return [destination tonightsBill];
    } else {
        NSLog(@"The destination object doesn't conform tonightsBill.");
        return nil;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel button pressed");
            break;
        case 1:
            [self openMailView:self];
            break;
        case 2:
            [self editBillData:self];
            break;
        default:
            break;
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([[self viewControllers][0] isKindOfClass:[MCSharedBillTableViewController class]]) {
        if (!editTripTableViewController) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
            editTripTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MCEditTripViewController"];
            [editTripTableViewController setTonightsBill:[self tonightsBill]];
            [editTripTableViewController setDelegate:self];
        }
        return editTripTableViewController;
    } else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([[self viewControllers][0] isKindOfClass:[MCEditTripViewController class]]) {
        if (!sharedBillTableViewController) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
            sharedBillTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MCSharedBillTableViewController"];
            [sharedBillTableViewController setTonightsBill:[self tonightsBill]];
            [sharedBillTableViewController setDelegate:self];
            [sharedBillTableViewController setMailDelegate:self];
        }
        return sharedBillTableViewController;
    } else {
        return nil;
    }
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished) {
        id destination = [self parentViewController];
        if ([[self viewControllers][0] isKindOfClass:[MCEditTripViewController class]]) {
            if ([destination conformsToProtocol:@protocol(MCCurrentViewDelegate)]) {
                [destination setCurrentView:MCSelectEditTripTableView];
            }
        } else {
            if ([destination conformsToProtocol:@protocol(MCCurrentViewDelegate)]) {
                [destination setCurrentView:MCSelectSharedBillTableView];
            }
        }
    }
    
    if (finished) {
        if ([[self viewControllers][0] isKindOfClass:[MCEditTripViewController class]]) {
            [[self pageViewIndicator] setCurrentPage:0];
            [[self titleLabel] setText:NSLocalizedString(@"PEOPLE_PRESENT_PAGEVIEWCONTROLLER", @"People present")];
        } else if ([[self viewControllers][0] isKindOfClass:[MCSharedBillTableViewController class]]) {
            [[self pageViewIndicator] setCurrentPage:1];
            [[self titleLabel] setText:NSLocalizedString(@"PAYMENTS_PAGEVIEWCONTROLLER", @"Payments")];
        }
    }
}

#pragma mark - Storyboard stuff

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] respondsToSelector:@selector(viewControllers)]) {
        if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setTonightsBill:)]) {
            [[[segue destinationViewController] viewControllers][0] setTonightsBill:[self tonightsBill]];
        }
        if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setSendMailObject:)]) {
            [[[segue destinationViewController] viewControllers][0] setSendMailObject:self];
        }
    }
}

@end
