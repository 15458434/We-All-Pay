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

@interface MCSharedBillPageViewController ()

@end

@implementation MCSharedBillPageViewController

@synthesize tonightsBill;

#pragma mark - actions

- (IBAction)toggleEdit:(id)sender
{
    if ([[[[self viewControllers] objectAtIndex:0] tableView] isEditing]) {
        [[[[self viewControllers] objectAtIndex:0] tableView] setEditing:NO animated:YES];
    } else {
        [[[[self viewControllers] objectAtIndex:0] tableView] setEditing:YES animated:YES];
    }
}

- (IBAction)solveBill:(id)sender
{
    
}

- (void)editBillData:(id)sender
{
    //[self performSegueWithIdentifier:@"openTripInfo" sender:self];
    [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    if ([[[self viewControllers] objectAtIndex:0] isKindOfClass:[MCSharedBillTableViewController class]]) {
        
    }
}

#pragma mark - new in this class

- (void)setSharedBillViewControllerFromStoryboard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
    MCSharedBillTableViewController *sharedBillView = [storyboard instantiateViewControllerWithIdentifier:@"MCSharedBillTableViewController"];
    [sharedBillView setTonightsBill:tonightsBill];
    [pageViewIndicator setCurrentPage:1];
    [titleLabel setText:@"Payments"];
    NSArray *views = [NSArray arrayWithObjects:sharedBillView, nil];
    [self setViewControllers:views direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    [self setDelegate:self];
    [self setDataSource:self];
}

- (void)setEditTripViewControllerFromStoryboard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
    MCEditTripViewController *editTripView = [storyboard instantiateViewControllerWithIdentifier:@"MCEditTripViewController"];
    [editTripView setTonightsBill:tonightsBill];
    NSArray *views = [NSArray arrayWithObjects:editTripView, nil];
    [pageViewIndicator setCurrentPage:0];
    [titleLabel setText:@"People present"];
    [self setViewControllers:views direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self setDelegate:self];
    [self setDataSource:self];
}

- (void)openMailView:(id)sender;
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController setMailComposeDelegate:sender];
    [mailViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    [mailViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[[mailViewController viewControllers] objectAtIndex:0] setEdgesForExtendedLayout:UIRectEdgeNone];
    NSArray *sda = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *allPeople = [[tonightsBill peoplePresent] sortedArrayUsingDescriptors:sda];
    // Create a list of all email addresses
    NSMutableArray *listOfMailAddresses = [[NSMutableArray alloc] init];
    for (MCPerson *p in allPeople) {
        if ([p defaultEmailAddress]) {
            [listOfMailAddresses addObject:[p defaultEmailAddress]];
        }
    }
    // Set the mail header.
    [mailViewController setToRecipients:listOfMailAddresses];
    [mailViewController setSubject:[[NSString alloc] initWithFormat:@"Bill overview of our trip to %@.", [tonightsBill tripName]]];
    
    // Generate the text for the email.
    NSMutableString *mailBody = [[NSMutableString alloc] init];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [mailBody appendFormat:@"Dear %@\n", [tonightsBill stringOfApproxPeoplePresent]];
    [mailBody appendFormat:@"\n"];
    [mailBody appendFormat:@"From a total of %@, which was spend on our last trip to %@. We all have to pay an equal share of %@.\n", [nf stringFromNumber:[tonightsBill totalSumOfMoneyOfThisSharedBill]], [tonightsBill tripName], [nf stringFromNumber:[tonightsBill amountPeopleShouldHavePaid]]];
    [mailBody appendFormat:@"\n"];
    if ([tonightsBill totalAmountOfPeopleWhoHavePaid] == 0) {
        [mailBody appendFormat:@"Nobody has paid so far.\n"];
    } else if ([tonightsBill totalAmountOfPeopleWhoHavePaid] == 1) {
        [mailBody appendFormat:@"The person who has payed:\n"];
    } else {
        [mailBody appendFormat:@"The persons who have paid are:\n"];
    }
    NSArray * allPayments = [[tonightsBill payments] sortedArrayUsingDescriptors:sda];
    for (MCPayment *p in allPayments) {
        [mailBody appendFormat:@"%@ has paid %@ for %@.\n", [[p payingPerson] getName], [nf stringFromNumber:[p money]], [p descriptionOfPayment]];
    }
    [mailBody appendFormat:@"\n"];
    [mailBody appendFormat:@"To equalize and have everybody pay the average of %@, I suggest the following solution:\n", [nf stringFromNumber:[tonightsBill amountPeopleShouldHavePaid]]];
    for (MCReturnPayment *rp in [tonightsBill solveWhoHasToPayWhoFromThisBill]) {
        [mailBody appendFormat:@"%@\n", [rp stringForMail]];
    }
    [mailBody appendFormat:@"\n"];
    [mailBody appendFormat:@"If you have any remarks please let me know.\n"];
    [mailViewController setMessageBody:mailBody isHTML:NO];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [MCTools setAdBannerIfNotPaid:NO forViewController:[[mailViewController viewControllers] objectAtIndex:0]];
    } else {
        [MCTools setAdBannerIfNotPaid:YES forViewController:[[mailViewController viewControllers] objectAtIndex:0]];
    }
    if (sender!=self) {
        [sender presentViewController:mailViewController animated:YES completion:nil];
    } else {
        [[self navigationController] presentViewController:mailViewController animated:YES completion:nil];
    }
}

- (void)shareBill:(id)sender
{
    if ([tonightsBill doesEveryoneHaveAnEmailAddress]) {
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
    
    if (!tonightsBill) {
        tonightsBill = [MCSharedBill addSharedBill];
        [self setEditTripViewControllerFromStoryboard];
    } else {
        [self setSharedBillViewControllerFromStoryboard];
    }
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MCTonightsBillTitleDelegate

@synthesize titleLabel;

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

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([[[self viewControllers] objectAtIndex:0] isKindOfClass:[MCEditTripViewController class]]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
        MCSharedBillTableViewController *sharedbillView = [storyboard instantiateViewControllerWithIdentifier:@"MCSharedBillTableViewController"];
        [sharedbillView setTonightsBill:tonightsBill];
        [sharedbillView setDelegate:self];
        return sharedbillView;
    } else {
        return nil;
    }
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed && finished) {
        if ([[[self viewControllers] objectAtIndex:0] isKindOfClass:[MCEditTripViewController class]]) {
            [pageViewIndicator setCurrentPage:0];
            [titleLabel setText:@"People present"];
        } else if ([[[self viewControllers] objectAtIndex:0] isKindOfClass:[MCSharedBillTableViewController class]]) {
            [pageViewIndicator setCurrentPage:1];
            [titleLabel setText:@"Payments"];
        }
    }
}

#pragma mark - Storyboard stuff

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] respondsToSelector:@selector(viewControllers)]) {
        if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setTonightsBill:)]) {
            [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setTonightsBill:tonightsBill];
        }
        if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setSendMailObject:)]) {
            [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setSendMailObject:self];
        }
    }
}

@end
