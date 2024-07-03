//
//  MCPageViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 22-12-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillPageViewController.h"

#import "MCSharedBillMainViewController.h"
#import "MCPaymentsTableViewController.h"
#import "MCEditTripViewController.h"
#import "MCReturnPaymentViewController.h"

#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"

#import "MCWeAllPayStoreController.h"

#import "We_all_pay-Swift.h"

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

- (void)peopleOrPaymentsSelectionControlTapped:(id)sender
{
    NSParameterAssert(_mainViewController);
#ifdef DEBUG
    NSLog(@"segmentedControllerPressed to value: %ld", (long)_mainViewController.peopleOrPaymentsSelectionControl.selectedSegmentIndex);
#endif
    NSInteger newIndex = _mainViewController.peopleOrPaymentsSelectionControl.selectedSegmentIndex;
#ifdef DEBUG
    NSLog(@"newIndex = %ld, _lastSetIndex = %ld", (long)newIndex, (long)_lastSetIndex);
#endif
    if (_lastSetIndex > newIndex) {
        __weak typeof(self) weakSelf = self;
        [self setViewControllers:@[[self viewControllerForIndex:newIndex]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
            // Finished.
            if (finished) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    strongSelf.lastSetIndex = newIndex;
                }
            } else {
#ifdef DEBUG
                NSLog(@"Moving down not finished.");
#endif
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    strongSelf.mainViewController.peopleOrPaymentsSelectionControl.selectedSegmentIndex = 1;
                }
            }
        }];
    } else if (_lastSetIndex < newIndex) {
        __weak typeof(self) weakSelf = self;
        UIViewController<MCIndexProtocol> *newViewController = [self viewControllerForIndex:newIndex];
        
        [self setViewControllers:@[newViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            // finished.
            if (finished) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    strongSelf.lastSetIndex = newIndex;
                }
            } else {
#ifdef DEBUG
                NSLog(@"Moving up not finished.");
#endif
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    strongSelf.mainViewController.peopleOrPaymentsSelectionControl.selectedSegmentIndex = 0;
                }
            }
        }];
    } else {
#ifdef DEBUG
        NSLog(@"This is not supposed to happen.");
#endif
        Class currentViewController = object_getClass(self.viewControllers.firstObject);
        NSString *currentViewControllerClassName = NSStringFromClass(currentViewController);
        if ([currentViewControllerClassName isEqualToString:@"MCEditTripViewController"]) {
#ifdef DEBUG
            NSLog(@"Switching to Payments");
#endif
            __weak typeof(self) weakSelf = self;
            UIViewController<MCIndexProtocol> *newViewController = [self viewControllerForIndex:newIndex];
            
            [self setViewControllers:@[newViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                // finished.
                if (finished) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf) {
                        strongSelf.lastSetIndex = newIndex;
                    }
                } else {
#ifdef DEBUG
                    NSLog(@"Switching to Payments not finished.");
#endif
                }
            }];
        }
        if ([currentViewControllerClassName isEqualToString:@"MCSharedBillTableViewController"]) {
#ifdef DEBUG
            NSLog(@"Switching to People");
#endif
            __weak typeof(self) weakSelf = self;
            [self setViewControllers:@[[self viewControllerForIndex:newIndex]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
                // Finished.
                if (finished) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf) {
                        strongSelf.lastSetIndex = newIndex;
                    }
                } else {
#ifdef DEBUG
                    NSLog(@"Switching to People not finished.");
#endif
                }
            }];
        }
    }
}

#pragma mark - new in this class

- (MCEditTripViewController *)editTripTableViewController {
    // if no editTripViewController create one.
    if (_editTripTableViewController) {
        return _editTripTableViewController;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
    _editTripTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MCEditTripViewController"];
    _editTripTableViewController.isEditingModel = _isEditingModel;
    _editTripTableViewController.index = 0;
    [_editTripTableViewController setTonightsBill:_tonightsBill];
    [self setDelegate:self];
    [self setDataSource:self];
    NSManagedObjectContext *backgroundContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
    [backgroundContext performBlock:^{
        if (self.writableTonightsBill) {
            [self.editTripTableViewController setWritableTonightsBill:self.writableTonightsBill];
            NSManagedObjectContext *mainContext = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
            [mainContext performBlock:^{
                [self.editTripTableViewController setTonightsBill:self.tonightsBill];
            }];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self.editTripTableViewController selector:@selector(writableTonightsBillIsCreated:) name:MCWritableTonightsBillReady object:self];
        }
    }];
    
    return _editTripTableViewController;
}

- (MCPaymentsTableViewController *)sharedBillTableViewController {
    // if no sharedBillTableViewController create one.
    if (_sharedBillTableViewController) {
        return _sharedBillTableViewController;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main-Iphone" bundle:nil];
    _sharedBillTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MCSharedBillTableViewController"];
    _sharedBillTableViewController.isEditingModel = _isEditingModel;
    _sharedBillTableViewController.index = 1;
    [_sharedBillTableViewController setTonightsBill:_tonightsBill];
    [_sharedBillTableViewController setMailDelegate:self];
    [self setDelegate:self];
    [self setDataSource:self];
    NSManagedObjectContext *backgroundContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
    [backgroundContext performBlock:^{
        if (self.writableTonightsBill) {
            [self.sharedBillTableViewController setWritableTonightsBill:self.writableTonightsBill];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self.sharedBillTableViewController selector:@selector(writableTonightsBillIsCreated:) name:MCWritableTonightsBillReady object:self];
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

#pragma mark - Inherited from super

- (void)viewDidLoad
{
#ifdef DEBUG
    NSLog(@"%@: viewDidLoad", self);
#endif
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[self navigationController] setToolbarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    switch (_mainViewController.peopleOrPaymentsSelectionControl.selectedSegmentIndex) {
        case 0:
        {
            _lastSetIndex = 0;
            MCEditTripViewController *myFirstView = (MCEditTripViewController *)[self viewControllerForIndex:0];
            __weak typeof(self) weakSelf = self;
            [self setViewControllers:@[myFirstView] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:^(BOOL finished) {
                if (finished) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf) {
                        strongSelf.mainViewController.peopleOrPaymentsSelectionControl.selectedSegmentIndex = 0;
                        strongSelf.lastSetIndex = 0;
                    }
                }
            }];
        }
            break;
        case 1:
        {
            _lastSetIndex = 1;
            MCPaymentsTableViewController *myFirstView = (MCPaymentsTableViewController *)[self viewControllerForIndex:1];
            __weak typeof(self) weakSelf = self;
            [self setViewControllers:@[myFirstView] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
                if (finished) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf) {
                        strongSelf.mainViewController.peopleOrPaymentsSelectionControl.selectedSegmentIndex = 1;
                        strongSelf.lastSetIndex = 1;
                    }
                }
            }];
        }
            break;
        default:
            NSLog(@"This is an invalid selection between people and payments.");
            abort();
            break;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void) setTonightsBill:(MCSharedBill  * _Nonnull )tonightsBill
{
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
    NSDictionary *userInfo = notification.userInfo;
    _writableTonightsBill = userInfo[MCwritableTonightsBillKey];
    NSManagedObjectID *tonightsBillID = _writableTonightsBill.objectID;
    NSManagedObjectContext *mainContext = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    __weak typeof(self) weakSelf = self;
    [mainContext performBlock:^{
        typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.tonightsBill = (MCSharedBill *)[mainContext objectWithID:tonightsBillID];
        }
    }];
#ifdef DEBUG
    NSLog(@"WritableTonightsBillIsCreated has been executed.");
#endif
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    UIViewController<MCIndexProtocol> *viewControllerWithIndexProtocol;
    if ([viewController conformsToProtocol:@protocol(MCIndexProtocol) ]) {
        viewControllerWithIndexProtocol = (UIViewController<MCIndexProtocol> *)viewController;
    } else {
#ifdef DEBUG
        NSLog(@"%@ should conform MCIndexProtocol", viewController);
#endif
    }
    if (viewControllerWithIndexProtocol.index == 0) {
        return nil;
    }
    NSInteger newIndex = viewControllerWithIndexProtocol.index - 1;
    UIViewController<MCIndexProtocol> *newViewController = [self viewControllerForIndex:newIndex];
    return newViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    UIViewController<MCIndexProtocol> *viewControllerWithIndexProtocol;
    if ([viewController conformsToProtocol:@protocol(MCIndexProtocol) ]) {
        viewControllerWithIndexProtocol = (UIViewController<MCIndexProtocol> *)viewController;
    } else {
#ifdef DEBUG
        NSLog(@"%@ should conform MCIndexProtocol", viewController);
#endif
    }
    if (viewControllerWithIndexProtocol.index == 1) {
        return nil;
    }
    NSInteger newIndex = viewControllerWithIndexProtocol.index + 1;
    UIViewController<MCIndexProtocol> *newViewController = [self viewControllerForIndex:newIndex];
    return newViewController;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
#ifdef DEBUG
    NSLog(@"willTranstistionToViewControllers: %@", pendingViewControllers);
#endif
    
}

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
            self.mainViewController.peopleOrPaymentsSelectionControl.selectedSegmentIndex = 0;
            _lastSetIndex = 0;
        } else if ([[self viewControllers][0] isKindOfClass:[MCPaymentsTableViewController class]]) {
            self.mainViewController.peopleOrPaymentsSelectionControl.selectedSegmentIndex = 1;
            _lastSetIndex = 1;
        }
    }
}

#pragma mark - Storyboard stuff

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//
//}

@end
