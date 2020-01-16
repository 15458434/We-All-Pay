//
//  MCSharedBillViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 02-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;
@import GoogleMobileAds;

#import "MCSharedBillViewController_iPad.h"

#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCWeAllPayStoreController.h"

#import "MCTools.h"
#import "MCDismissMeBlockProtocol.h"

#import "We_all_pay-Swift.h"

@interface MCSharedBillViewController_iPad ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *worstSalesPitchEverViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraintToLeftContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraintToRightContainerView;

@property (weak, nonatomic) IBOutlet UITextField *tripNameField;
@property (weak, nonatomic) IBOutlet UIView *leftTopView;

@property (strong, nonatomic) IBOutlet MCInterstitialAdEngine *interstitialAdEngine;

@property (strong, nonatomic) ContactsDataReceiver *contactsInserter;

@end

@implementation MCSharedBillViewController_iPad

#pragma mark - Actions

- (IBAction)solveButtonPressed:(id)sender
{
    [FIRAnalytics logEventWithName:@"Solve pressed" parameters:nil];
    if (_tonightsBill.peoplePresent.count == 0) {
        NSString *title = NSLocalizedString(@"Add some people first", @"Title for an alert message, because there are no people added to this event.");
        NSString *message = NSLocalizedString(@"You can't add a payment when no people are present. There is no one to split the expenses among.", @"A message to the user thay can't add a payment when they didn't add people to the even.");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        NSString *cancelActionTitle = NSLocalizedString(@"Cancel", @"Text on button to cancel something");
        [alertController addAction:[UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if ([_tonightsBill doAllPaymentHaveAPayer]) {
        [self performSegueWithIdentifier:@"openSolutionView" sender:self];
    } else {
        // Give user alert.
        NSString *title = NSLocalizedString(@"UNABLE_TO_SOLVE", @"Unable to solve");
        NSString *message = NSLocalizedString(@"At least one of the payments is missing a payer.", @"One of the payments is missing a payer.");
        NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"Text on button to cancel something");
        NSString *fixItButtonTitle = NSLocalizedString(@"Go to", @"Go to");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // don't do a thing.
        }]];
        __weak typeof(self) weakSelf = self;
        [alertController addAction:[UIAlertAction actionWithTitle:fixItButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf openFirstPaymentWithoutAPayer];
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)editButtonPressed:(id)sender
{
    
    static BOOL isEditingMode = NO;
    NSArray *myKids = [self childViewControllers];
    for (id kid in myKids) {
        if ([kid respondsToSelector:@selector(setEditing:)]) {
            if (isEditingMode) {
                [kid setEditing:NO];
            } else {
                [kid setEditing:YES];
            }
        }
    }
    isEditingMode = !isEditingMode;
    if (isEditingMode) {
        [FIRAnalytics logEventWithName:@"Edit Pressed" parameters:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonPressed:)];
        [[self navigationItem] setRightBarButtonItem:doneButton];
    } else {
        [FIRAnalytics logEventWithName:@"Done Pressed" parameters:nil];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
        [[self navigationItem] setRightBarButtonItem:editButton];
    }
}

- (IBAction)addressBookButtonPressed:(id)sender
{
    [FIRAnalytics logEventWithName:@"Contacts pressed" parameters:nil];
    if (!_contactsInserter) {
        _contactsInserter = [[ContactsDataReceiver alloc] initWith:_tonightsBill];
    }
    [_contactsInserter presentContactsPickerWith:self completion:^{
#ifdef DEBUG
        NSLog(@"I love Ilse.");
#endif
    }];
}

- (IBAction)addPaymentPressed:(id)sender
{
    [FIRAnalytics logEventWithName:@"Add Person pressed" parameters:nil];
    if (_tonightsBill.peoplePresent.count == 0) {
        NSString *title = NSLocalizedString(@"Add some people first", @"Title for an alert message, because there are no people added to this event.");
        NSString *message = NSLocalizedString(@"You can't add a payment when no people are present. There is no one to split the expenses among.", @"A message to the user thay can't add a payment when they didn't add people to the even.");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        NSString *cancelActionTitle = NSLocalizedString(@"Cancel", @"Text on button to cancel something");
        [alertController addAction:[UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    [self performSegueWithIdentifier:@"newPayment" sender:self];
}


#pragma mark - New in this class

- (void)putBannerOnScreen:(BOOL)animate
{
    BOOL isNotPurchased = ![[MCStoreInterface defaultStoreInterface] isProProductPurchased];
    if (isNotPurchased) {
        if (animate) {
#ifdef DEBUG
            NSLog(@"animating banner on screen.");
#endif
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.bottomLayoutConstraintToLeftContainerView.priority = UILayoutPriorityDefaultHigh - 1;
                self.bottomLayoutConstraintToRightContainerView.priority = UILayoutPriorityDefaultHigh - 1;
                [[self view] layoutIfNeeded];
            } completion:nil];
        } else {
#ifdef DEBUG
            NSLog(@"putting banner on screen immediately.");
#endif
            self.bottomLayoutConstraintToLeftContainerView.priority = UILayoutPriorityDefaultHigh - 1;
            self.bottomLayoutConstraintToRightContainerView.priority = UILayoutPriorityDefaultHigh - 1;
            [[self view] layoutIfNeeded];
        }
    } else {
        [self putBannerOffScreen:animate];
    }
}

- (void)putBannerOffScreen:(BOOL)animate
{
    if (animate) {
#ifdef DEBUG
        NSLog(@"animating banner off screen.");
#endif
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.bottomLayoutConstraintToLeftContainerView.priority = UILayoutPriorityDefaultHigh + 1;
            self.bottomLayoutConstraintToRightContainerView.priority = UILayoutPriorityDefaultHigh + 1;
            [[self view] layoutIfNeeded];
        } completion:nil];
    } else {
#ifdef DEBUG
        NSLog(@"putting banner off screen immediately.");
#endif
        self.bottomLayoutConstraintToLeftContainerView.priority = UILayoutPriorityDefaultHigh + 1;
        self.bottomLayoutConstraintToRightContainerView.priority = UILayoutPriorityDefaultHigh + 1;
        [[self view] layoutIfNeeded];
    }
}

- (void)openFirstPaymentWithoutAPayer
{
    [self performSegueWithIdentifier:@"firstPaymentWithoutPayer" sender:self];
}

#pragma mark - Notifications

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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _tripNameField) {
        return YES;
    } else {
#ifdef DEBUG
        NSLog(@"There is only one textField in this ViewController.");
#endif
        return NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _tripNameField) {
        [FIRAnalytics logEventWithName:@"Begin edit Event name" parameters:nil];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _tripNameField) {
        [FIRAnalytics logEventWithName:@"End edit Event name" parameters:nil];
        [_tonightsBill setTripName:[_tripNameField text]];
    }
}

#pragma mark - MCGenericAdBannerViewController

- (NSString *)adUnitId {
    return @"ca-app-pub-5354415674074435/1457854707";
}

#pragma mark - AdEngineDelegate

- (void)adEngine:(MCAdEngine *)adEngine putOnScreenBannerView:(GADBannerView *)bannerView {
    [self putBannerOnScreen:YES];
}

- (void)adEngine:(MCAdEngine *)adEngine putOffScreenBannerView:(GADBannerView *)bannerView {
    if (adEngine) {
        [self putBannerOffScreen:YES];
    } else {
        [self putBannerOffScreen:NO];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    // Hide AdBanner
    self.bottomLayoutConstraintToLeftContainerView.priority = UILayoutPriorityDefaultHigh + 1;
    self.bottomLayoutConstraintToRightContainerView.priority = UILayoutPriorityDefaultHigh + 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_leftTopView bringSubviewToFront:_tripNameField];
    [_tripNameField setText:[_tonightsBill tripName]];
    
    // Set the color of the backButton.
    UIColor *backButtonColor = [Colors getButtonColor];
    [[[self navigationController] navigationBar] setTintColor:backButtonColor];
    [[[self navigationItem] rightBarButtonItem] setTintColor:backButtonColor];
    
    // TODO: Add observer for notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyProVersion:) name:[ MCStoreInterface applyProVersionNotification] object:[MCStoreInterface defaultStoreInterface]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundHandler:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // TODO: Remove observer for notifications.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[MCStoreInterface applyProVersionNotification] object:[MCStoreInterface defaultStoreInterface]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // When newPerson segue is used add a person to tonightsBill.
    if ([[segue identifier] isEqualToString:@"newPerson"]) {
        id destination = [[segue destinationViewController] viewControllers][0];
        if ([destination conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
            [destination setTonightsBill:_tonightsBill];
        }
    }
    
    // When newPerson segue is used to add a new payment to tonightsbill.
    if ([[segue identifier] isEqualToString:@"newPayment"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        if (@available(iOS 13.0, *)) {
            navController.modalInPresentation = YES;
        }
        PaymentViewController *destination = (PaymentViewController *)navController.viewControllers.firstObject;
        destination.tonightsBill = _tonightsBill;
    }
    
    // Use this string to open payment view with the first payment without payer.
    if ([segue.identifier isEqualToString:@"firstPaymentWithoutPayer"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        if (@available(iOS 13.0, *)) {
            navController.modalInPresentation = YES;
        }
        PaymentViewController *destination = (PaymentViewController *)navController.viewControllers.firstObject;
        destination.tonightsBill = _tonightsBill;
        destination.thisPayment = [_tonightsBill getFirstPaymentWithoutAPayer];
    }
    
    // When openSolutionView is used to go to the solution screen.
    if ([[segue identifier] isEqualToString:@"openSolutionView"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        SolutionTableViewController_iPad *destination = (SolutionTableViewController_iPad *)navController.viewControllers.firstObject;
        __weak MCSharedBillViewController_iPad *weakSelf = self;
        [destination updateAdEngine:_interstitialAdEngine andEvent:_tonightsBill andDismissBlock:^{
            MCSharedBillViewController_iPad *strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

#pragma mark - UIContentContainer

#pragma mark - UIResponder

#pragma mark - NSObject

@end
