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

#import "MCMailComposer.h"

#import "MCTitleViewDelegate.h"
#import "MCCurrentViewDelegate.h"

NSInteger const minPageIndex = 0;
NSInteger const maxPageIndex = 1;

@interface MCSharedBillPageViewController ()

@property (nonatomic) NSInteger lastSetIndex;

@end

@implementation MCSharedBillPageViewController

#pragma mark - actions

- (BOOL)toggleEditTableView:(id)sender
{
    if ([[[self viewControllers][0] tableView] isEditing]) {
        [[[self viewControllers][0] tableView] setEditing:NO animated:YES];
        return NO;
    } else {
        [[[self viewControllers][0] tableView] setEditing:YES animated:YES];
        return YES;
    }
}

- (IBAction)pageControlTapped:(id)sender
{
    if (sender == _pageControl) {
#if DEBUG
        NSLog(@"pageControlTapped");
#endif
    }
}


- (void)editBillData:(id)sender
{
    //[self performSegueWithIdentifier:@"openTripInfo" sender:self];
    [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    if ([[self viewControllers][0] isKindOfClass:[MCSharedBillTableViewController class]]) {
        
    }
}

#pragma mark - new in this class

- (MCEditTripViewController *)editTripTableViewController
{
    // if no editTripViewController create one.
    if (_editTripTableViewController) {
        return _editTripTableViewController;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
    _editTripTableViewController.index = 0;
    _editTripTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MCEditTripViewController"];
    [_editTripTableViewController setTonightsBill:[self tonightsBill]];
    [self setDelegate:self];
    [self setDataSource:self];
    NSManagedObjectContext *backgroundContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
    [backgroundContext performBlock:^{
        if (_writableTonightsBill) {
            [_editTripTableViewController setWritableTonightsBill:_writableTonightsBill];
            NSManagedObjectContext *mainContext = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
            [mainContext performBlock:^{
                [_editTripTableViewController setTonightsBill:_tonightsBill];
            }];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:_editTripTableViewController selector:@selector(writableTonightsBillIsCreated:) name:MCWritableTonightsBillReady object:self];
        }
    }];
    
    return _editTripTableViewController;
}

- (MCSharedBillTableViewController *)sharedBillTableViewController
{
    // if no sharedBillTableViewController create one.
    if (_sharedBillTableViewController) {
        return _sharedBillTableViewController;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
    _sharedBillTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MCSharedBillTableViewController"];
    _sharedBillTableViewController.index = 1;
    [_sharedBillTableViewController setTonightsBill:[self tonightsBill]];
    [_sharedBillTableViewController setMailDelegate:self];
    [self setDelegate:self];
    [self setDataSource:self];
    NSManagedObjectContext *backgroundContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
    [backgroundContext performBlock:^{
        if (_writableTonightsBill) {
            [_sharedBillTableViewController setWritableTonightsBill:_writableTonightsBill];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:_sharedBillTableViewController selector:@selector(writableTonightsBillIsCreated:) name:MCWritableTonightsBillReady object:self];
        }
    }];
    
    return _sharedBillTableViewController;
}

- (UIViewController<MCIndexProtocol> *)viewControllerForIndex:(NSInteger)index
{
#if DEBUG
    NSLog(@"Index is %d", index);
#endif
    switch (index) {
        case 0:
            return [self editTripTableViewController];
        case 1:
            return [self sharedBillTableViewController];
        default:
            NSLog(@"Out of bounds, this shouldn't be happening.");
            return nil;
    }
}

- (void)openMailView:(id)sender
{
#if DEBUG
    NSLog(@"%@ openMailView:%@", self, sender);
#endif
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController setMailComposeDelegate:sender];
    [mailViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    [mailViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[mailViewController viewControllers][0] setEdgesForExtendedLayout:UIRectEdgeNone];
    
    // Init the mailComposer
    MCMailComposer *mailComposer = [[MCMailComposer alloc] init];
    [mailComposer setTonightsBill:[self tonightsBill]];
    [mailComposer setIsHTML:NO];
    [mailComposer setSolution:[[self tonightsBill] solveWhoHasToPayWhoFromThisBill]];
    
    [mailViewController setToRecipients:[mailComposer getMailAddresses]];
    [mailViewController setSubject:[mailComposer getSubject]];
    [mailViewController setMessageBody:[mailComposer getMailBody] isHTML:NO];
    
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
    
    [[self navigationController] setToolbarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id destination = [self parentViewController];
    NSParameterAssert([destination conformsToProtocol:@protocol(MCTonightsBillTransfer)]);
    NSParameterAssert([destination conformsToProtocol:@protocol(MCCurrentViewDelegate)]);
    
    if ([destination currentView] == MCSelectSharedBillTableView) {
        _lastSetIndex = 1;
        MCSharedBillTableViewController *myFirstView = (MCSharedBillTableViewController *)[self viewControllerForIndex:1];
        __weak typeof(self) weakSelf = self;
        [self setViewControllers:@[myFirstView] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
            if (finished) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    strongSelf.pageControl.currentPage = 1;
                    strongSelf.titleLabel.text = NSLocalizedString(@"PAYMENTS_PAGEVIEWCONTROLLER", @"Payments");
                }
            }
        }];
    } else {
        _lastSetIndex = 0;
        MCEditTripViewController *myFirstView = (MCEditTripViewController *)[self viewControllerForIndex:0];
        __weak typeof(self) weakSelf = self;
        [self setViewControllers:@[myFirstView] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:^(BOOL finished) {
            if (finished) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    strongSelf.pageControl.currentPage = 0;
                    strongSelf.titleLabel.text = NSLocalizedString(@"PEOPLE_PRESENT_PAGEVIEWCONTROLLER", @"People present");
                }
            }
        }];
        
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if ([destination conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
        return [destination tonightsBill];
    } else {
        NSLog(@"The destination object doesn't conform tonightsBill.");
        return nil;
    }
}

- (MCSharedBill *)writeableTonightsBill
{
    // This should be executed on the private thread.
    id destination = [self parentViewController];
    if ([destination conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
        return [destination writeableTonightsBill];
    } else {
        NSLog(@"The destination object doesn't conform tonightsBill.");
        return nil;
    }
}

- (void)writeableTonightsBillIsCreated:(NSNotification *)notification
{
    // Should be executed on the background thread.
    NSDictionary *userInfo = [notification userInfo];
    _writableTonightsBill = [userInfo objectForKey:MCwritableTonightsBillKey];
    NSManagedObjectID *tonightsBillID = [_writableTonightsBill objectID];
    NSManagedObjectContext *mainContext = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    [mainContext performBlock:^{
        _tonightsBill = (MCSharedBill *)[mainContext objectWithID:tonightsBillID];
    }];
    NSLog(@"WritableTonightsBillIsCreated has been executed.");
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
    UIViewController<MCIndexProtocol> *viewControllerWithIndexProtocol;
    if ([viewController conformsToProtocol:@protocol(MCIndexProtocol) ]) {
        viewControllerWithIndexProtocol = (UIViewController<MCIndexProtocol> *)viewController;
    } else {
        NSLog(@"%@ should conform MCIndexProtocol", viewController);
    }
    if (viewControllerWithIndexProtocol.index == 0) {
        return nil;
    }
    NSInteger newIndex = viewControllerWithIndexProtocol.index - 1;
    return [self viewControllerForIndex:newIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    UIViewController<MCIndexProtocol> *viewControllerWithIndexProtocol;
    if ([viewController conformsToProtocol:@protocol(MCIndexProtocol) ]) {
        viewControllerWithIndexProtocol = (UIViewController<MCIndexProtocol> *)viewController;
    } else {
        NSLog(@"%@ should conform MCIndexProtocol", viewController);
    }
    if (viewControllerWithIndexProtocol.index == 1) {
        return nil;
    }
    NSInteger newIndex = viewControllerWithIndexProtocol.index + 1;
    
    return [self viewControllerForIndex:newIndex];
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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//
//}

@end
