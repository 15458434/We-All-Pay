//
//  MCPaymentViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 29-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCPaymentViewController.h"

#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCPaymentPresence+addons.h"
#import "MCWeAllPayStoreController.h"

#import "MCDismissMeBlockProtocol.h"

#import "We_all_pay-Swift.h"

typedef NS_ENUM(BOOL, ChildViewStatus) {
    ChildViewStatusIsNotOpened,
    ChildViewStatusIsOpened
};

@interface MCPaymentViewController () <MCAdBannerEngineDelegate>

@property (weak, nonatomic) IBOutlet UITextField *payerNameField;
@property (strong, nonatomic) MCPayerTextInputPicker *payerTextInputPicker;
@property (weak, nonatomic) IBOutlet UITextField *itemView;
@property (strong, nonatomic) MCDescriptionOfPaymentTextInputValidator *itemViewDelegate;
@property (weak, nonatomic) IBOutlet UITextField *paidView;
@property (strong, nonatomic) IBOutlet MCMoneyTextInputValidator *paidViewDelegate;

@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIImageView *payerPicture;
@property (weak, nonatomic) IBOutlet UIImageView *categoryView;
@property (nonatomic) ChildViewStatus selectCurrencyTableViewController;

@property (strong, nonatomic) UIBarButtonItem *theDoneButton;
@property (strong, nonatomic) UIBarButtonItem *cancelChangesForEntirePaymentButton;
@property (strong, nonatomic) MCTwoLabelsTitleView *twoLabelTitleView;

@property (weak, nonatomic) IBOutlet UIView *bannerContainerView;

@property (strong, nonatomic) MCPerson *payerViewPerson;
@property (strong, nonatomic) NSNumber *paidViewNumber;

@property (nonatomic, strong) NSArray *paymentPresenceArray;
@property (nonatomic, strong) NSFetchedResultsController *dataController;

@property (nonatomic, strong) UIPickerView *personPickerView;
@property (nonatomic, strong) NSArray<MCPerson *> *listOfPeople;
@property (nonatomic) BOOL peoplePickerCancelled;

@property (nonatomic, strong) IBOutlet MCPaymentModel *model;

@property (nonatomic) MCMoneyValueFieldDismissStatus kindOfPaidFieldDismiss;

@end

@implementation MCPaymentViewController

@synthesize delegate;

- (IBAction)tabElseWhereAndDismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)mainCancelButtonPressed:(id)sender {
    [self.view endEditing:YES];
    if ([[[[MCWeAllPayStoreController defaultStore] mainThreadContext] undoManager] canUndo]) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mainDoneButtonPressed:(id)sender {
#ifdef DEBUG
    NSLog(@"MCPaymentViewController: Done button pressed.");
#endif
    [self.view endEditing:YES];
    
    NSString *descriptionOfPayment = [_thisPayment.descriptionOfPayment stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSString *parameterItemID = [NSString stringWithFormat:@"id-%@", descriptionOfPayment];
    NSString *parameterName = [NSString stringWithFormat:@"%@", descriptionOfPayment];
    NSString *paremeterContentType = @"shared_payment";
    [FIRAnalytics logEventWithName:@"save_item" parameters:@{kFIRParameterItemID: parameterItemID, kFIRParameterItemName: parameterName, kFIRParameterContentType: paremeterContentType}];

    if (MCWeAllPayStoreController.defaultStore.mainThreadContext.undoManager.canUndo) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [WhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:self.tonightsBill];
    }];
}

- (IBAction)currencySelectionPressed:(id)sender {
#ifdef DEBUG
    NSLog(@"%@, currencySelectionPressed", self);
#endif
    _kindOfPaidFieldDismiss = MCMoneyValueFieldDismissStatusCurrencySelectionTapped;
    [self.view endEditing:YES];
    
    [self performSegueWithIdentifier:@"openSelectCurrency" sender:self];
}

- (IBAction)selectCategoryPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"selectCategory" sender:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)tappedInTheBackground:(id)selector
{
    _kindOfPaidFieldDismiss = MCMoneyValueFieldDismissStatusBackgroundTapped;
    [self.view endEditing:YES];
}

- (void)showCategory {
    // Get category picture.
    NSArray *pictureObjects = CategoryPictureStoreController.shared.pictureObjects;
    CategoryPictureObject *categoryObject = pictureObjects[_thisPayment.categoryId.shortValue];
    if (categoryObject.categoryId > 0) {
        _categoryView.image = categoryObject.largePicture;
        [_categoryButton setTitle:categoryObject.categoryDescription forState:UIControlStateNormal];
    } else {
        NSString *buttonText = NSLocalizedString(@"SELECT_CATEGORY", @"Select Category");
        _categoryView.image = categoryObject.largePicture;
        [_categoryButton setTitle:buttonText forState:UIControlStateNormal];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.isViewLoaded && self.view.window) {
        [[self tableView] beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.isViewLoaded && self.view.window) {
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_thisPayment.currency.code];
                _paidView.text = [cf stringForObjectValue:_thisPayment.money];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.isViewLoaded && self.view.window) {
        [[self tableView] endUpdates];
    }
}

#pragma mark - MCGenericAdBannerTableViewController

- (NSString *)adUnitId {
#ifdef DEBUG
    // This is a test Unit ID for banner from Google themselves.
    return @"ca-app-pub-3940256099942544/2934735716";
#else
    return @"ca-app-pub-5354415674074435/2765341863";
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

#pragma mark - UITableViewController

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_dataController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPaymentPresenceTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentPresenceCell_iPhone" forIndexPath:indexPath];
    
    // Set the cell contents
    MCPaymentPresence *thisCellsPresence = [_dataController objectAtIndexPath:indexPath];
    cell.nameLabel.text = thisCellsPresence.person.getFullName;
    cell.personView.image = thisCellsPresence.person.thumbnail;
    [[cell isPresentSwitch] setOn:[[thisCellsPresence isPersonPresent] boolValue]];
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:thisCellsPresence.payment.currency.code];
    NSNumber *averageOwe = @(-thisCellsPresence.averageOweFromPayment.doubleValue);
    cell.owesLabel.text = [cf stringForObjectValue:averageOwe];
    cell.thisCellsPaymentPresence = thisCellsPresence;
    
    // Set the cell alignment to headerView stuff
    NSLayoutConstraint *payerViewToCellNameLabel = [NSLayoutConstraint constraintWithItem:_payerNameField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[cell nameLabel] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-6.0];
    payerViewToCellNameLabel.identifier = [[thisCellsPresence.person getFullName] stringByAppendingString:@"payerViewToCellNameLabel"];
    NSLayoutConstraint *payerPictureToUser = [NSLayoutConstraint constraintWithItem:_payerPicture attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[cell personView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    payerPictureToUser.identifier = [[thisCellsPresence.person getFullName] stringByAppendingString:@"payerPictureToUser"];
    [[self tableView] addConstraints:@[payerViewToCellNameLabel, payerPictureToUser]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return UITableViewAutomaticDimension;
//}
//
#pragma mark - UIViewController

- (void)viewDidLoad {
    MCRemoteConfigEngine *configEngine = [[MCRemoteConfigEngine alloc] init];
    self.adBannerEngine.shouldShowEngine = [[MCRemoteConfigTrueCasino alloc] initWithEngine:configEngine andRemoteConfigItem:ConfigEngineItemPercentageOfTimeShowPaymentViewBannerOniPhone];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[MCWeAllPayStoreController defaultStore] beginUndoGroup];
    
    // When _thisPayment was not passed along a new one should be created.
    if (!_thisPayment) {
        _thisPayment = [_tonightsBill addPayment];
        _isNew = YES;
        if (_pathComponentsToOpen) {
            _thisPayment.payingPerson = _pathComponentsToOpen.lastObject;
        }
//        didSomethingChange = YES;
    } else {
        _isNew = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    [_model prepareForUseWithPayment:_thisPayment andChangeHandler:^(MCPayment * _Nonnull payment) {
        [weakSelf showCategory];
        weakSelf.payerPicture.image = payment.payingPerson.picture;
        weakSelf.payerNameField.text = payment.payingPerson.getFullName;
    }];
    
    // If tonight's bill wasn't passed along.
    NSParameterAssert(_tonightsBill);
    
    _payerTextInputPicker = [[MCPayerTextInputPicker alloc] initWith:_model and:_payerNameField];
    _itemViewDelegate = [[MCDescriptionOfPaymentTextInputValidator alloc] initWithModel:_model andTextField:_itemView];
    
    // Make sure a tap in the background dismisses the keyboard as well.
    UITapGestureRecognizer *thatTickles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInTheBackground:)];
    [thatTickles setCancelsTouchesInView:YES];
    [[self tableView] addGestureRecognizer:thatTickles];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.adBannerEngine.isReady) {
        self.worstSalesPitchEverView.alpha = 1;
    } else {
        self.worstSalesPitchEverView.alpha = 0;
    }
    
    // Navigationbar stuff
    if (!_twoLabelTitleView) {
        _twoLabelTitleView = [[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        if (_isNew) {
            [[_twoLabelTitleView mainLabel] setText:NSLocalizedString(@"NEW_PAYMENT_HEADER", @"Header in the paymentView which state new Payment")];
            [[_twoLabelTitleView subLabel] setText:NSLocalizedString(@"NEW_PAYMENT_SUBHEADER", @"Sub header in the paymentView which states Add payment data")];
        } else {
            [[_twoLabelTitleView mainLabel] setText:NSLocalizedString(@"EXISTING_PAYMENT_HEADER", @"Header in the paymentView which states payment")];
            [[_twoLabelTitleView subLabel] setText:NSLocalizedString(@"EXISTING_PAYMENT_SUBHEADER", @"Sub header in the paymentView which states edit payment data")];
        }
        [[self navigationItem] setTitleView:_twoLabelTitleView];
    }
    
    if (!_dataController) {
        _dataController = [[MCWeAllPayStoreController defaultStore] paymentPresenceDataControllerForDelegate:self];
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_thisPayment.currency.code];
        _paidView.text = [cf stringForObjectValue:_thisPayment.money];
        [[self tableView] reloadData];
        _selectCurrencyTableViewController = ChildViewStatusIsNotOpened;
    }
    [[self tableView] reloadData];
    
    // Fill in the form if data is present.
    _payerNameField.text = _model.payment.payingPerson.getFullName;
    _itemView.text = _model.payment.descriptionOfPayment;
    if ([_thisPayment payingPerson]) {
        _payerPicture.image = _thisPayment.payingPerson.picture;
    }
    [self showCategory];
    if (!_isNew || _selectCurrencyTableViewController == ChildViewStatusIsOpened) {
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_thisPayment.currency.code];
        _paidView.text = [cf stringForObjectValue:_thisPayment.money];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"openSelectCurrency"]) {
#ifdef DEBUG
        NSLog(@"%@, prepareForSegue openSelectCurrency", self);
#endif
        _selectCurrencyTableViewController = ChildViewStatusIsOpened;
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        SelectCurrencyTableViewController *selectCurrencyViewController = (SelectCurrencyTableViewController *)navController.viewControllers.firstObject;
        selectCurrencyViewController.currencyUpdateModel = [[PaymentUpdateCurrencyModel alloc] initWith:_thisPayment];
    }
    if ([segue.identifier isEqualToString:@"selectCategory"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SelectCategoryTableViewController *destinationViewController = (SelectCategoryTableViewController *)navigationController.viewControllers.firstObject;
        __weak typeof(self) weakSelf = self;
        [destinationViewController prepareForUseWithPayment:_model.payment andChangeHandler:^(MCPayment * _Nonnull payment) {
            [weakSelf showCategory];
        }];
    }
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)awakeFromNib {
    [super awakeFromNib];
    _selectCurrencyTableViewController = ChildViewStatusIsNotOpened;
}

@end
