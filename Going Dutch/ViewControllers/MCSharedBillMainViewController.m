//
//  MCSharedBillMainViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import GoogleMobileAds;
@import FirebaseAnalytics;

#import "MCSharedBillMainViewController.h"

#import "MCSharedBillPageViewController.h"

#import "MCSharedBill+addons.h"

#import "MCWeAllPayStoreController.h"

#import "We_all_pay-Swift.h"

@interface MCSharedBillMainViewController ()

@property (strong, nonatomic) MCSharedBillPageViewController *pageViewController;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *worstSalesPitchEverViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *worstSalesPitchEverViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutContraintAdBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutCustomContainer;

@end

@implementation MCSharedBillMainViewController

#pragma mark - IBActions

- (IBAction)toggleEdit:(id)sender {
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

- (IBAction)peopleOrPaymentsSelectionChangedValue:(id)sender {
    [_pageViewController peopleOrPaymentsSelectionControlTapped:self];
}

#pragma mark - private functions

- (void)putBannerOnScreen:(BOOL)animate {
    BOOL isNotPurchased = ![[MCStoreInterface defaultStoreInterface] isProProductPurchased];
    if (isNotPurchased) {
        if (animate) {
#ifdef DEBUG
            NSLog(@"animating banner on screen.");
#endif
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.bottomLayoutCustomContainer.priority = UILayoutPriorityDefaultHigh - 1;
                [[self view] layoutIfNeeded];
            } completion:nil];
        } else {
#ifdef DEBUG
            NSLog(@"putting banner on screen immediately.");
#endif
            self.bottomLayoutCustomContainer.priority = UILayoutPriorityDefaultHigh - 1;
            [[self view] layoutIfNeeded];
        }
    } else {
        [self putBannerOffScreen:animate];
    }

}

- (void)putBannerOffScreen:(BOOL)animate {
    if (animate) {
#ifdef DEBUG
        NSLog(@"animating banner off screen.");
#endif
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.bottomLayoutCustomContainer.priority = UILayoutPriorityDefaultHigh + 1;
            [[self view] layoutIfNeeded];
        } completion:nil];
    } else {
#ifdef DEBUG
        NSLog(@"putting banner off screen immediately.");
#endif
        self.bottomLayoutCustomContainer.priority = UILayoutPriorityDefaultHigh + 1;
        [[self view] layoutIfNeeded];
    }
}

#pragma mark - AdEngineDelegate

- (void)adEngine:(MCAdEngine *)adEngine putOnScreenBannerView:(GADBannerView *)bannerView {
    [self putBannerOnScreen:YES];
}

- (void)adEngine:(MCAdEngine *)adEngine putOffScreenBannerView:(GADBannerView *)bannerView {
    if (adEngine) {
        [self putBannerOffScreen:YES];
    } else {
        [self putBannerOnScreen:NO];
    }
}

#pragma mark - Notification Handlers

- (void)applyProVersion:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakSelf adEngine:weakSelf.adBannerEngine putOffScreenBannerView:self.worstSalesPitchEverView];
        weakSelf.worstSalesPitchEverView.autoloadEnabled = NO;
    }];
}

- (void)applicationWillEnterForegroundHandler:(NSNotification *) notication {
    BOOL isNotPurchased = ![[MCStoreInterface defaultStoreInterface] isProProductPurchased];
    if (isNotPurchased) {
        [self.adBannerEngine prepareAdBanner:self.worstSalesPitchEverView withAdUnitId:self.adUnitId andViewController:self];
    }
}

#pragma mark - From UIViewController+WeAllPayStore

- (void)storeDidChange:(NSNotification *)notification {
    if (!_tonightsBill) {
        NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
        [context performBlock:^{
            self.tonightsBill = (MCSharedBill *)[context objectWithID:[self.writableTonightsBill objectID]];
        }];
    }
}

#pragma mark - Inherited from super

- (NSString *)adUnitId {
#ifdef DEBUG
    // This is a test Unit ID for banner from Google themselves.
    return @"ca-app-pub-3940256099942544/2934735716";
#else
    return @"ca-app-pub-5354415674074435/1457854707";
#endif
}

- (void)viewDidLoad {
#ifdef SCREENSHOTS
#else
    MCAdEngine.isEnabled = !MCStoreInterface.defaultStoreInterface.isProProductPurchased;
#endif
    MCRemoteConfigEngine *configEngine = [[MCRemoteConfigEngine alloc] init];
    self.adBannerEngine.shouldShowEngine = [[MCRemoteConfigTrueCasino alloc] initWithEngine:configEngine andRemoteConfigItem:ConfigEngineItemPercentageOfTimeShowMainBottomBannerOniPhone];
     
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    _peopleOrPaymentsSelectionControl.subviews[0].accessibilityIdentifier = @"People";
    _peopleOrPaymentsSelectionControl.subviews[1].accessibilityIdentifier = @"Payments";
    
    [self startRespondingToStoreChangeNotifications];
    
    if (!_tonightsBill) {
        _tonightsBill = [MCSharedBill addSharedBillToContext:[[MCWeAllPayStoreController defaultStore] mainThreadContext]];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
        _currentView = MCSelectEditTripTableView;
    } else {
        _currentView = MCSelectSharedBillTableView;
    }
    _pageViewController.tonightsBill = _tonightsBill;
    
    self.bottomLayoutCustomContainer.priority = UILayoutPriorityDefaultHigh + 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyProVersion:) name:[MCStoreInterface applyProVersionNotification] object:[MCStoreInterface defaultStoreInterface]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundHandler:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[MCStoreInterface applyProVersionNotification] object:[MCStoreInterface defaultStoreInterface]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        // Parent is null when back button is pressed in navigationbar
        [self.view endEditing:YES];
        [_tonightsBill deleteIfStillNew];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    if ([[segue identifier] isEqualToString:@"pageViewController"]) {
        _pageViewController = (MCSharedBillPageViewController *)[segue destinationViewController];
        _pageViewController.mainViewController = self;
        if (_tonightsBill.peoplePresent.count > 0) {
            self.peopleOrPaymentsSelectionControl.selectedSegmentIndex = 1;
        } else {
            self.peopleOrPaymentsSelectionControl.selectedSegmentIndex = 0;
        }
        NSManagedObjectContext *backgroundContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
        [backgroundContext performBlock:^{
            id<MCTonightsBillTransfer> destination = (id<MCTonightsBillTransfer>)[segue destinationViewController];
            if (self.writableTonightsBill) {
                [destination setWritableTonightsBill:self.writableTonightsBill];
                NSManagedObjectContext *mainContext = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
                [mainContext performBlock:^{
                    [destination setTonightsBill:self.tonightsBill];
                }];
            } else {
                SEL writeableTonightsBillIsCreated = NSSelectorFromString(@"writeableTonightsBillIsCreated:");
                [[NSNotificationCenter defaultCenter] addObserver:destination selector:writeableTonightsBillIsCreated name:MCWritableTonightsBillReady object:nil];
            }
        }];
    }
}

@end
