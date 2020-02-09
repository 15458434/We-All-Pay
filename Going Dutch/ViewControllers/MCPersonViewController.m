//
//  MCPersonViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCPersonViewController.h"

#import "MCWeAllPayStoreController.h"
#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCEmailAddress+addons.h"

#import "MCTools.h"

@interface MCPersonViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) MCTwoLabelsTitleView *twoLabelTitleView;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *pictureView;
@property (nonatomic, weak) IBOutlet UITextField *firstNameField;
@property (nonatomic, strong) MCNameTextInputValidator *firstNameFieldValidator;
@property (nonatomic, weak) IBOutlet UITextField *lastNameField;
@property (nonatomic, strong) MCNameTextInputValidator *familyNameFieldValidator;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UIButton *selectEmailAddressButton;
@property (nonatomic, strong) MCEmailTextInputProxy *emailTextInputReceiver;

@property (nonatomic, strong) IBOutlet MCScrollViewAdjusterToKeyboard *keyboardNotificationHandler;
@property (nonatomic, strong) IBOutlet MCPersonModel *model;

@end

@implementation MCPersonViewController

- (IBAction)cancelButtonPressed:(id)sender
{
    [FIRAnalytics logEventWithName:@"Cancel button pressed" parameters:nil];
    [self.view endEditing:YES];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectEmailAddressPressed:(id)sender {
    [FIRAnalytics logEventWithName:@"Select email address pressed" parameters:nil];
    // If any of the fields is first responder resign them first.
    [self.view endEditing:YES];
    
    UIViewController *presenting = self.navigationController.presentingViewController;
    if (presenting.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular && presenting.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        // iPad size
        [self performSegueWithIdentifier:@"openSelectEmailAddress" sender:self];
    } else {
        // iPhone sizes
        _emailTextInputReceiver.target = MCEmailTextInputProxyTargetPicker;
        UIPickerView *inputView = [[UIPickerView alloc] init];
        inputView.delegate = _emailTextInputReceiver;
        inputView.dataSource = _emailTextInputReceiver;
        inputView.showsSelectionIndicator = YES;
        [inputView selectRow:_model.indexOfDefaultEmailAddress inComponent:0 animated:YES];
        _emailField.inputView = inputView;
        _emailField.tintColor = UIColor.clearColor;
        [_emailField becomeFirstResponder];
    }
}

- (IBAction)doneButtonPressed:(id)sender
{
    [FIRAnalytics logEventWithName:@"Done button pressed" parameters:nil];
    [self.view endEditing:YES];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSAssert((indexPath.section == 0), @"IndexPath section should be 0");
    if ([controller isEqual:_model.personFetchedResultsController]) {
        MCPerson *person = (MCPerson *)anObject;
        switch (type) {
            case NSFetchedResultsChangeInsert:
                self.firstNameField.text = person.firstName;
                self.lastNameField.text = person.lastName;
                self.pictureView.image = person.picture;
                break;
            case NSFetchedResultsChangeUpdate:
                self.firstNameField.text = person.firstName;
                self.lastNameField.text = person.lastName;
                self.pictureView.image = person.picture;
                break;
            case NSFetchedResultsChangeMove:
                NSParameterAssert(NO);
                break;
            case NSFetchedResultsChangeDelete:
                break;
            default:
                break;
        }
    } else if ([controller isEqual:_model.defaultEmailAddressFetchedResultsController]) {
        switch (type) {
            case NSFetchedResultsChangeInsert:
                self.emailField.text = [(MCEmailAddress *)anObject emailAddress];
                break;
            case NSFetchedResultsChangeUpdate:
                self.emailField.text = [(MCEmailAddress *)anObject emailAddress];
                break;
            case NSFetchedResultsChangeMove:
                NSParameterAssert(NO);
                break;
            case NSFetchedResultsChangeDelete:
                break;
            default:
                break;
        }
    }
}

#pragma mark - MCGenericMediumAdBannerViewController

- (NSString *)adUnitId {
#ifdef DEBUG
    // This is a test Unit ID for banner from Google themselves.
    return @"ca-app-pub-3940256099942544/2934735716";
#else
    return @"ca-app-pub-5354415674074435/6095865179";
#endif
}

#pragma mark - MCAdBannerEngineDelegate

- (void)adEngine:(MCAdBannerEngine *)adEngine putOnScreenBannerView:(GADBannerView *)bannerView {
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.worstSalesPitchEverView.alpha = 1;
    } completion:nil];
}

- (void)adEngine:(MCAdBannerEngine *)adEngine putOffScreenBannerView:(GADBannerView *)bannerView {
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.worstSalesPitchEverView.alpha = 0;
    } completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    MCRemoteConfigEngine *configEngine = [[MCRemoteConfigEngine alloc] init];
    self.adBannerEngine.shouldShowEngine = [[MCRemoteConfigTrueCasino alloc] initWithEngine:configEngine andRemoteConfigItem:ConfigEngineItemPercentageOfTimeShowPersonViewBannerOniPhone];
    
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [_model prepareForUseWithPerson:_thisPerson andFetchedResultsControllerDelegate:self andChangeHandler:^(MCPerson * _Nonnull person) {
        typeof(self) strongSelf = weakSelf;
        NSParameterAssert(strongSelf);
        
        strongSelf.emailField.inputView = nil;
        strongSelf.emailField.tintColor = UIColor.systemBlueColor;
        strongSelf.emailTextInputReceiver.target = MCEmailTextInputProxyTargetValidator;
        strongSelf.selectEmailAddressButton.hidden = person.emailAddress.count > 1 ? NO : YES;
    }];
    _firstNameFieldValidator = [[MCNameTextInputValidator alloc] initWithModel:_model andTextField:_firstNameField andConfig:MCNameTextInputValidatorConfigFirstName];
    _familyNameFieldValidator = [[MCNameTextInputValidator alloc] initWithModel:_model andTextField:_lastNameField andConfig:MCNameTextInputValidatorConfigFamilyName];
    MCEmailTextInputValidator *validator = [[MCEmailTextInputValidator alloc] initWithTextField:_emailField andModel:_model];
    MCEmailTextInputPicker *picker = [[MCEmailTextInputPicker alloc] initWithTextField:_emailField andModel:_model];
    _emailTextInputReceiver = [[MCEmailTextInputProxy alloc] initWithValidator:validator andPicker:picker andTarget:MCEmailTextInputProxyTargetValidator];
    
    [_keyboardNotificationHandler prepareForUseWithScrollView:_scrollView andTextFields:@[_firstNameField, _lastNameField, _emailField]];
    
    self.worstSalesPitchEverView.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.firstNameField.text = _model.person.firstName;
    self.lastNameField.text = _model.person.lastName;
    self.emailField.text = _model.person.defaultEmailAddress;
    self.pictureView.image = _model.person.picture;
    self.selectEmailAddressButton.hidden = _model.person.emailAddress.count > 1 ? NO : YES;
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (!_twoLabelTitleView) {
        _twoLabelTitleView = [[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        _twoLabelTitleView.mainLabel.text = NSLocalizedString(@"Person", @"Header in the personView which state new person.");
        if (_isNew) {
            _twoLabelTitleView.subLabel.text = NSLocalizedString(@"Add", @"Sub header in the personView which states add new data");
        } else {
            _twoLabelTitleView.subLabel.text = NSLocalizedString(@"Edit", @"Sub header in the personView which state edit data");
        }

        self.navigationItem.titleView = _twoLabelTitleView;
    }
    
    // Dismiss the keyboard on backgroundtap.
    [self startResigningFirstResponderOnBackgroundTap];
    
    [_keyboardNotificationHandler start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_keyboardNotificationHandler stop];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"openSelectEmailAddress"]) {
        __weak SelectEmailAddressTableViewController_iPad *destination = [segue destinationViewController];
        destination.thisPerson = _thisPerson;
        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
            [destination setDismissMe:^{
                [FIRAnalytics logEventWithName:@"dismiss select email address" parameters:nil];
                if (destination) {
                    [destination dismissViewControllerAnimated:YES completion:^{
                        self.emailField.text = self.thisPerson.defaultEmailAddress;
                    }];
                }
            }];
        }
    }
}

#pragma mark - UIResponder

#pragma mark - NSObject

@end
