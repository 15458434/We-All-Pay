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

@interface MCSharedBillMainViewController () <GADBannerViewDelegate>


@property (strong, nonatomic) MCSharedBillPageViewController *pageViewController;

@property (nonatomic, readonly) GADRequest *generalAdRequest;
@property (weak, nonatomic) IBOutlet GADBannerView *worstSalesPitchEverView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *worstSalesPitchEverViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *worstSalesPitchEverViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutContraintAdBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutCustomContainer;

@end

@implementation MCSharedBillMainViewController

#pragma mark - IBActions

- (IBAction)toggleEdit:(id)sender {
    if ([[self childViewControllers][0] toggleEditTableView:sender]) {
        [FIRAnalytics logEventWithName:@"Edit Pressed" parameters:nil];
        // Set Done Button
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEdit:)];
        [[self navigationItem] setRightBarButtonItem:doneButton];
    } else {
        [FIRAnalytics logEventWithName:@"Done Pressed" parameters:nil];
        // Set Edit Button
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)];
        [[self navigationItem] setRightBarButtonItem:editButton];
    }
}

- (IBAction)peopleOrPaymentsSelectionChangedValue:(id)sender {
    [_pageViewController peopleOrPaymentsSelectionControlTapped:self];
}

#pragma mark - private functions

- (GADRequest *)generalAdRequest {
    GADRequest *request = [GADRequest request];
#ifdef DEBUG
    NSString *iPhoneX = @"3a960c027f1ea390326793600324a891";
    NSString *iPadRetina = @"63f51db641e29b85012042e407de3cba";
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[kGADSimulatorID, iPhoneX, iPadRetina];
#endif
    return request;
}

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

- (void)updateBannerSize:(CGSize)size {
    if (size.height > size.width) {
        self.worstSalesPitchEverView.adSize = kGADAdSizeSmartBannerPortrait;
    } else {
        self.worstSalesPitchEverView.adSize = kGADAdSizeSmartBannerLandscape;
    }
    
    if (size.height <= 400) {
        self.worstSalesPitchEverViewHeight.constant = 32;
    } else if (size.height > 400 && size.height <= 720) {
        self.worstSalesPitchEverViewHeight.constant = 50;
    } else if (size.height > 720) {
        self.worstSalesPitchEverViewHeight.constant = 90;
    }
}

- (void)prepareWorstSalesPitchEverView {
#ifdef SCREENSHOTS
    self.worstSalesPitchEverView.autoloadEnabled = NO;
#else
    BOOL isNotPurchased = ![[MCStoreInterface defaultStoreInterface] isProProductPurchased];
    if (isNotPurchased) {
        NSParameterAssert(_worstSalesPitchEverView);
        [[self worstSalesPitchEverView] layoutIfNeeded];
        [self updateBannerSize:[[UIScreen mainScreen] bounds].size];
        
        self.worstSalesPitchEverView.rootViewController = self;
        self.worstSalesPitchEverView.delegate = self;
        [[self worstSalesPitchEverView] loadRequest:self.generalAdRequest];
        self.worstSalesPitchEverView.autoloadEnabled = YES;
    } else {
        self.worstSalesPitchEverView.autoloadEnabled = NO;
    }
#endif
}

#pragma mark - Notification Handlers

- (void)applyProVersion:(NSNotification *)notification {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self putBannerOffScreen:YES];
        self.worstSalesPitchEverView.autoloadEnabled = NO;
    }];
}

- (void)applicationWillEnterForegroundHandler:(NSNotification *) notication {
    BOOL isNotPurchased = ![[MCStoreInterface defaultStoreInterface] isProProductPurchased];
    if (isNotPurchased) {
        GADRequest *request = [self generalAdRequest];
        [[self worstSalesPitchEverView] loadRequest:request];
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

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
#ifdef DEBUG
    NSLog(@"Yes, I got something.");
#endif
    [self putBannerOnScreen:YES];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
#ifdef DEBUG
    NSLog(@"Oh no, I didn't get anything, because %@", error);
#endif
    [self putBannerOffScreen:YES];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    [FIRAnalytics logEventWithName:@"Press AdBanner" parameters:nil];
}

- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
    [FIRAnalytics logEventWithName:@"Dismiss full screen ad" parameters:nil];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
    [FIRAnalytics logEventWithName:@"Take me to the product" parameters:nil];
}

#pragma mark - Inherited from super

- (void)viewDidLoad {
#ifdef DEBUG
    NSLog(@"%@ viewDidLoad", self);
#endif
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
    [self prepareWorstSalesPitchEverView];
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
        
        UIView *firstResponder = [[self view] getFirstResponder];
        if (firstResponder) {
            [firstResponder resignFirstResponder];
        }
        [_tonightsBill deleteIfStillNew];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self putBannerOffScreen:NO];
        [self updateBannerSize:size];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
#ifdef DEBUG
    NSLog(@"prepareForSegue: %@", [segue identifier]);
#endif
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
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
