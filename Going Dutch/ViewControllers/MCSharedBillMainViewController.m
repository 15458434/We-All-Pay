//
//  MCSharedBillMainViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillMainViewController.h"

#import "MCSharedBill+addons.h"

#import "UIView+MCAddons.h"

#import "MCWeAllPayStoreController.h"

@interface MCSharedBillMainViewController ()

@property (nonatomic, strong) MCSharedBill *writableTonightsBill;

@end

@implementation MCSharedBillMainViewController

#pragma mark - private functions

- (IBAction)toggleEdit:(id)sender
{
    [[self childViewControllers][0] toggleEdit:sender];
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
    
    if (![self tonightsBill]) {
        NSManagedObjectContext *writeContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
        [writeContext performBlock:^{
            _writableTonightsBill = [MCSharedBill addSharedBillToContext:writeContext];
            [[MCWeAllPayStoreController defaultStore] saveStore];
            NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
            [dc postNotificationName:MCWritableTonightsBillReady object:self userInfo:@{MCwritableTonightsBillKey: _writableTonightsBill}];
        }];
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
        NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
        [context performBlock:^{
            [_writableTonightsBill deleteIfStillNew];
            [[MCWeAllPayStoreController defaultStore] saveStore];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self stopRespondingToStorechangeNotifications];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"pageViewController"]) {
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
