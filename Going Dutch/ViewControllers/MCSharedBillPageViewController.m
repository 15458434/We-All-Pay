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

#import "We_all_pay-Swift.h"

#import "MCTitleViewDelegate.h"
#import "MCCurrentViewDelegate.h"

NSInteger const minPageIndex = 0;
NSInteger const maxPageIndex = 1;

@interface MCSharedBillPageViewController ()

@property (nonatomic) NSInteger lastSetIndex;
@property (nonatomic) BOOL isChildTableViewEditing;

@end

@implementation MCSharedBillPageViewController

@synthesize tonightsBill = _tonightsBill;

#pragma mark - actions

- (BOOL)toggleEditTableView:(id)sender
{
#if DEBUG
    NSNumber *freakyBooleaon = @([[[self viewControllers][0] tableView] isEditing]);
    NSLog(@"toggleEditTableView: %@", freakyBooleaon);
#endif
    if ([[[self viewControllers][0] tableView] isEditing]) {
        _isChildTableViewEditing = NO;
        [[[self viewControllers][0] tableView] setEditing:_isChildTableViewEditing animated:YES];
        return NO;
    } else {
        _isChildTableViewEditing = YES;
        [[[self viewControllers][0] tableView] setEditing:_isChildTableViewEditing animated:YES];
        return YES;
    }
}

- (void)pageControlTapped:(id)sender
{
    if (sender == _pageControl) {
#if DEBUG
        NSLog(@"pageControlTapped to value: %ld", (long)_pageControl.currentPage);
#endif
        NSInteger newIndex = _pageControl.currentPage;
        if (_lastSetIndex > _pageControl.currentPage) {
            __weak typeof(self) weakSelf = self;
            [self setViewControllers:@[[self viewControllerForIndex:newIndex]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
                // Finished.
                if (finished) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf) {
                        strongSelf.lastSetIndex = newIndex;
                        strongSelf.titleLabel.text = [strongSelf viewTitleForIndex:newIndex];
                    }
                } else {
                    NSLog(@"Moving down not finished.");
                }

            }];
        } else if (_lastSetIndex < _pageControl.currentPage) {
            __weak typeof(self) weakSelf = self;
            UIViewController<MCIndexProtocol> *newViewController = [self viewControllerForIndex:newIndex];
            
            [self setViewControllers:@[newViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                // finished.
                if (finished) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf) {
                        strongSelf.lastSetIndex = newIndex;
                        strongSelf.titleLabel.text = [strongSelf viewTitleForIndex:newIndex];
                    }
                } else {
                    NSLog(@"Moving up not finished.");
                }
            }];
        } else {
            NSLog(@"This is not supposed to happen.");
        }
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
    _editTripTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MCEditTripViewController"];
    _editTripTableViewController.index = 0;
    _editTripTableViewController.myParent = self;
    [_editTripTableViewController setTonightsBill:_tonightsBill];
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
    _sharedBillTableViewController.myParent = self;
    [_sharedBillTableViewController setTonightsBill:_tonightsBill];
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
    switch (index) {
        case 0:
            return (UIViewController<MCIndexProtocol> *)[self editTripTableViewController];
        case 1:
            return (UIViewController<MCIndexProtocol> *)[self sharedBillTableViewController];
        default:
            NSLog(@"Out of bounds, this shouldn't be happening.");
            return nil;
    }
}

- (NSString *)viewTitleForIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return NSLocalizedString(@"PEOPLE_PRESENT_PAGEVIEWCONTROLLER", @"People present");
        case 1:
            return NSLocalizedString(@"PAYMENTS_PAGEVIEWCONTROLLER", @"Payments");
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
    MCMailComposer *mailComposer = [[MCMailComposer alloc] initWithTonightsBill:[self tonightsBill]];
    
    [mailViewController setToRecipients:[mailComposer getMailAddresses]];
    [mailViewController setSubject:[mailComposer getSubject]];
    [mailViewController setMessageBody:[mailComposer getMailBody] isHTML:mailComposer.isHTML];
    
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
        NSString *title = NSLocalizedString(@"EMAIL_CONSTRUCTION_FAILURE_TITLE", @"Unable to send email to all people.");
        NSString *message = NSLocalizedString(@"EMAIL_CONSTRUCTION_FAILURE_MESSAGE", @"Reason: Not all people have a mail address.");
        NSString *cancel = NSLocalizedString(@"CANCEL", @"Cancel");
        NSString *sendAnyway = NSLocalizedString(@"SEND_ANYWAY", @"Send anyway");
        UIAlertView *mailAddressesMissing = [[UIAlertView alloc] initWithTitle:title
                                                                       message:message
                                                                      delegate:self
                                                             cancelButtonTitle:cancel
                                                             otherButtonTitles:sendAnyway, nil];
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
#if DEBUG
    NSLog(@"%@: viewDidLoad", self);
#endif
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
                    strongSelf.lastSetIndex = 1;
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
                    strongSelf.lastSetIndex = 0;
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

#pragma mark - MCTonightsBillTransfer

- (MCSharedBill *)tonightsBill
{
    if (!_tonightsBill) {
        id destination = [self parentViewController];
        if ([destination conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
            _tonightsBill = [destination tonightsBill];
            return _tonightsBill;
        } else {
            NSLog(@"The destination object doesn't conform tonightsBill.");
            return nil;
        }
    } else {
        return _tonightsBill;
    }
}

- (void) setTonightsBill:(MCSharedBill *)tonightsBill
{
    if (!tonightsBill) {
        abort();
    }
    [self willChangeValueForKey:@"tonightsBill"];
    _tonightsBill = tonightsBill;
    [self didChangeValueForKey:@"tonightsBill"];
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
    UIViewController<MCIndexProtocol> *newViewController = [self viewControllerForIndex:newIndex];
//    if ([newViewController isKindOfClass:[UITableViewController class]]) {
//        UITableViewController *myNewTableViewController = (UITableViewController *)newViewController;
//        [[myNewTableViewController tableView] setEditing:_isChildTableViewEditing animated:NO];
//    }
    return newViewController;
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
    UIViewController<MCIndexProtocol> *newViewController = [self viewControllerForIndex:newIndex];
//    if ([newViewController isKindOfClass:[UITableViewController class]]) {
//        UITableViewController *myNewTableViewController = (UITableViewController *)newViewController;
//        [[myNewTableViewController tableView] setEditing:_isChildTableViewEditing animated:NO];
//    }
    return newViewController;
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
            _lastSetIndex = 0;
            [[self titleLabel] setText:NSLocalizedString(@"PEOPLE_PRESENT_PAGEVIEWCONTROLLER", @"People present")];
        } else if ([[self viewControllers][0] isKindOfClass:[MCSharedBillTableViewController class]]) {
            [[self pageViewIndicator] setCurrentPage:1];
            _lastSetIndex = 1;
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
