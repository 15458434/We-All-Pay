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

static void * isEditingToggleContext = &isEditingToggleContext;

@interface MCSharedBillMainViewController ()

@property (strong, nonatomic) MCSharedBillPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet MCEventModel *eventModel;
@property (strong, nonatomic) IBOutlet MCToggleModel *isEditingModel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *worstSalesPitchEverViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *worstSalesPitchEverViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutContraintAdBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutCustomContainer;

@end

@implementation MCSharedBillMainViewController

- (void)updateEventWithObjectID:(NSManagedObjectID *)objectID {
    NSManagedObjectContext *managedObjectContext = MCWeAllPayStoreController.defaultStore.mainThreadContext;
    MCSharedBill *event = [managedObjectContext objectWithID:objectID];
    self.tonightsBill = event;
}

- (void)prepareForUseWithEventModel:(MCEventModel *)model {
    _eventModel = model;
}

- (IBAction)toggleEdit:(id)sender {
    [_isEditingModel toggle];
}

- (IBAction)peopleOrPaymentsSelectionChangedValue:(id)sender {
    [_pageViewController peopleOrPaymentsSelectionControlTapped:self];
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
                [self.view layoutIfNeeded];
            } completion:nil];
        } else {
#ifdef DEBUG
            NSLog(@"putting banner on screen immediately.");
#endif
            self.bottomLayoutCustomContainer.priority = UILayoutPriorityDefaultHigh - 1;
            [self.view layoutIfNeeded];
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
            [self.view layoutIfNeeded];
        } completion:nil];
    } else {
#ifdef DEBUG
        NSLog(@"putting banner off screen immediately.");
#endif
        self.bottomLayoutCustomContainer.priority = UILayoutPriorityDefaultHigh + 1;
        [self.view layoutIfNeeded];
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

#pragma mark - MCPathComponentsToOpenProtocol

- (void)prepareForUseWithPathComponentsToOpen:(NSArray<NSManagedObject *> *)pathComponentsToOpen {
    MCSharedBill *event = (MCSharedBill *)pathComponentsToOpen[0];
    NSParameterAssert(event);
    
    [self updateEventWithObjectID:event.objectID];
}

#pragma mark - MCGenericAdBannerViewController

- (NSString *)adUnitId {
    return @"ca-app-pub-5354415674074435/1457854707";
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

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    UISegmentedControl *topSegmentedControl = self.peopleOrPaymentsSelectionControl;
    NSString *selectPeopleButton = NSLocalizedStringWithDefaultValue(@"event_view_segmentedControl_people_title", nil, NSBundle.mainBundle, @"People", @"A selection button at the top of the event view that allows for selection between the people and the payments on the event. This button is for selecting the people.");
    [topSegmentedControl setTitle:selectPeopleButton forSegmentAtIndex:0];
    NSString *selectPaymentsButton = NSLocalizedStringWithDefaultValue(@"event_view_segmentedControl_payments_title", nil, NSBundle.mainBundle, @"Payments", @"A selection button at the top of the event view that allows for selection between the people and the payments on the event. This button is for selecting the payments.");
    [topSegmentedControl setTitle:selectPaymentsButton forSegmentAtIndex:1];
    topSegmentedControl.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
    [topSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.systemBackgroundColor} forState:UIControlStateNormal];
    [topSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.systemBackgroundColor} forState:UIControlStateSelected];
    topSegmentedControl.selectedSegmentTintColor = [UIColor colorWithWhite:1.0 alpha:0.25];
}

- (void)viewDidLoad {
#ifdef SCREENSHOTS
#else
    MCAdEngine.isEnabled = !MCStoreInterface.defaultStoreInterface.isProProductPurchased;
#endif
     
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    _peopleOrPaymentsSelectionControl.subviews[0].accessibilityIdentifier = @"People";
    _peopleOrPaymentsSelectionControl.subviews[1].accessibilityIdentifier = @"Payments";
    
    [self startRespondingToStoreChangeNotifications];
    
    _pageViewController.tonightsBill = _eventModel.event;
    
    self.bottomLayoutCustomContainer.priority = UILayoutPriorityDefaultHigh + 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyProVersion:) name:[MCStoreInterface applyProVersionNotification] object:[MCStoreInterface defaultStoreInterface]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundHandler:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // Create KVO
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [self.isEditingModel addObserver:self forKeyPath:@"boolValue" options:options context:isEditingToggleContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // Destroy KVO
    [self.isEditingModel removeObserver:self forKeyPath:@"boolValue" context:isEditingToggleContext];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[MCStoreInterface applyProVersionNotification] object:[MCStoreInterface defaultStoreInterface]];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        // Parent is null when back button is pressed in navigationbar
        [self.view endEditing:YES];
        [_eventModel deleteIfStillNew];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"pageViewController"]) {
        _pageViewController = (MCSharedBillPageViewController *)[segue destinationViewController];
        _pageViewController.mainViewController = self;
        _pageViewController.isEditingModel = _isEditingModel;
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

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == isEditingToggleContext) {
#ifdef DEBUG
        NSLog(@"change: %@", change);
#endif
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting:
            {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[NSNumber class]]) {
                    NSNumber *newValue = (NSNumber *)new;
                    BOOL boolValue = newValue.boolValue;
                    if (boolValue) {
                        // Set Done Button
                        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEdit:)];
                        self.navigationItem.rightBarButtonItem = doneButton;
                    } else {
                        // Set Edit Button
                        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)];
                        self.navigationItem.rightBarButtonItem = editButton;
                    }
                }
            }
                break;
            default:
                break;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
