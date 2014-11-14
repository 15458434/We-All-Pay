//
//  MCSharedBillMainViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillMainViewController.h"

#import "MCSharedBillPageViewController.h"

#import "MCSharedBill+addons.h"

#import "UIView+MCAddons.h"

#import "MCWeAllPayStoreController.h"

@interface MCSharedBillMainViewController ()


@property (strong, nonatomic) IBOutlet MCSharedBillPageViewController *pageViewController;
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;

@end

@implementation MCSharedBillMainViewController

#pragma mark - private functions

- (IBAction)toggleEdit:(id)sender
{
    if ([[self childViewControllers][0] toggleEditTableView:sender]) {
        // Set Done Button
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEdit:)];
        [[self navigationItem] setRightBarButtonItem:doneButton];
    } else {
        // Set Edit Button
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)];
        [[self navigationItem] setRightBarButtonItem:editButton];
    }
}

#pragma mark - From UIViewController+WeAllPayStore

- (void)storeDidChange:(NSNotification *)notification
{
    if (!_tonightsBill) {
        NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
        [context performBlock:^{
            _tonightsBill = (MCSharedBill *)[context objectWithID:[_writableTonightsBill objectID]];
        }];
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
    [[self navigationController] setToolbarHidden:YES animated:YES];
    [MCTools setAdBannerIfNotPaid:YES forViewController:self];
    
    [self startRespondingToStoreChangeNotifications];
    
    if (!_tonightsBill) {
        _tonightsBill = [MCSharedBill addSharedBillToContext:[[MCWeAllPayStoreController defaultStore] mainThreadContext]];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
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

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        // Parent is null when back button is pressed in navigationbar
        
        UIView *firstResponder = [[self view] getFirstResponder];
        if (firstResponder) {
            [firstResponder resignFirstResponder];
        }
        [_tonightsBill deleteIfStillNew];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
//        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"pageViewController"]) {
        _pageViewController = (MCSharedBillPageViewController *)[segue destinationViewController];
        _pageViewController.pageControl = _pageIndicator;
        NSManagedObjectContext *backgroundContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
        [backgroundContext performBlock:^{
            id<MCTonightsBillTransfer> destination = [segue destinationViewController];
            if (_writableTonightsBill) {
                [destination setWritableTonightsBill:_writableTonightsBill];
                NSManagedObjectContext *mainContext = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
                [mainContext performBlock:^{
                    [destination setTonightsBill:_tonightsBill];
                }];
            } else {
                [[NSNotificationCenter defaultCenter] addObserver:destination selector:@selector(writeableTonightsBillIsCreated:) name:MCWritableTonightsBillReady object:nil];
            }
        }];
    }
}

@end
