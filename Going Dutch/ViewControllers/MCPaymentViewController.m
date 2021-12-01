//
//  MCPaymentViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 29-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCPaymentViewController.h"
#import "MCPaymentPresenceTableViewCell_iPhone.h"

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

static void * PayingPersonContext = &PayingPersonContext;
static void * DescriptionOfPaymentContext = &DescriptionOfPaymentContext;
static void * MoneyContext = &MoneyContext;
static void * CategoryIdContext = &CategoryIdContext;
static void * CurrencyContext = &CurrencyContext;

@interface MCPaymentViewController () <MCAdBannerEngineDelegate>

@property (weak, nonatomic) IBOutlet UITableViewHeaderFooterView *headerView;
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
    
    NSString *descriptionOfPayment = [_model.payment.descriptionOfPayment stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
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
        [WhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:self.model.payment.onWhichBill];
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)tappedInTheBackground:(id)selector {
    _kindOfPaidFieldDismiss = MCMoneyValueFieldDismissStatusBackgroundTapped;
    [self.view endEditing:YES];
}

- (void)prepareForUseWithEvent:(MCSharedBill *)event {
    NSParameterAssert(event);
    [[MCWeAllPayStoreController defaultStore] beginUndoGroup];
    MCPayment *newPayment = [event addPayment];
    _isNew = YES;
    [_model prepareForUseWithPayment:newPayment];
}

- (void)prepareForUseWithPayment:(MCPayment *)payment {
    NSParameterAssert(payment);
    [[MCWeAllPayStoreController defaultStore] beginUndoGroup];
    _isNew = NO;
    [_model prepareForUseWithPayment:payment];
}

#pragma mark - MCPathComponentsToOpenProtocol

- (void)prepareForUseWithPathComponentsToOpen:(NSArray<NSManagedObject *> *)pathComponentsToOpen {
    MCSharedBill *event = (MCSharedBill *)pathComponentsToOpen[0];
    NSParameterAssert(event);
    [self prepareForUseWithEvent:event];
    MCPerson *predefinedPayingPerson = (MCPerson *)pathComponentsToOpen[1];
    NSParameterAssert(predefinedPayingPerson);
    [_model updatePayingPerson:predefinedPayingPerson];
}

#pragma mark - MCPaymentStateModelProtocol

- (MCPaymentModel *)paymentStateModel {
    NSParameterAssert(_model);
    return _model;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - MCGenericAdBannerTableViewController

- (NSString *)adUnitId {
    return @"ca-app-pub-5354415674074435/2765341863";
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPaymentPresenceTableViewCell_iPhone *paymentPresenceCell = (MCPaymentPresenceTableViewCell_iPhone *)cell;
    // Set the cell contents
    MCPaymentPresence *paymentPresence = [_model.peoplePresenceController objectAtIndexPath:indexPath];
    [paymentPresenceCell updatePaymentPresence:paymentPresence];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _model.peoplePresenceController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPaymentPresenceTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentPresenceCell_iPhone" forIndexPath:indexPath];
    
    // Set the cell contents
    MCPaymentPresence *thisCellsPresence = [_model.peoplePresenceController objectAtIndexPath:indexPath];
    
    // Set the cell alignment to headerView stuff
    NSLayoutConstraint *payerViewToCellNameLabel = [NSLayoutConstraint constraintWithItem:_payerNameField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[cell nameLabel] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-6.0];
    payerViewToCellNameLabel.identifier = [[thisCellsPresence.person getFullName] stringByAppendingString:@"payerViewToCellNameLabel"];
    NSLayoutConstraint *payerPictureToUser = [NSLayoutConstraint constraintWithItem:_payerPicture attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[cell personView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    payerPictureToUser.identifier = [[thisCellsPresence.person getFullName] stringByAppendingString:@"payerPictureToUser"];
    [self.tableView addConstraints:@[payerViewToCellNameLabel, payerPictureToUser]];
    
    return cell;
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    // Load the titleView for the title bar.
    if (!_twoLabelTitleView) {
        _twoLabelTitleView = [NSBundle.mainBundle loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        if (_isNew) {
            _twoLabelTitleView.mainLabel.text = NSLocalizedString(@"New payment", @"Header in the paymentView which state new Payment");
            _twoLabelTitleView.subLabel.text = NSLocalizedString(@"Add payment data", @"Sub header in the paymentView which states Add payment data");
        } else {
            _twoLabelTitleView.mainLabel.text = NSLocalizedString(@"Payment", @"Header in the paymentView which states payment");
            _twoLabelTitleView.subLabel.text = NSLocalizedString(@"Edit payment data", @"Sub header in the paymentView which states edit payment data");
        }
        self.navigationItem.titleView = _twoLabelTitleView;
    }
    
    // Make sure a tap in the background dismisses the keyboard as well.
    UITapGestureRecognizer *thatTickles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInTheBackground:)];
    thatTickles.cancelsTouchesInView = YES;
    [self.tableView addGestureRecognizer:thatTickles];
    
    // Set the height constraint for the ad banner.
    self.worstSalesPitchEverHeightConstraint.constant = (CGFloat)[[[MCRemoteConfigEngine alloc] init] numberFor:MCRemoteConfigEngineItemPaymentAdBannerHeight].doubleValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _payerTextInputPicker = [[MCPayerTextInputPicker alloc] initWith:_model and:_payerNameField];
    _itemViewDelegate = [[MCDescriptionOfPaymentTextInputValidator alloc] initWithModel:_model andTextField:_itemView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.adBannerEngine.isReady) {
        self.worstSalesPitchEverView.alpha = 1;
    } else {
        self.worstSalesPitchEverView.alpha = 0;
    }

    _model.peoplePresenceController.delegate = self;
    NSError *fetchError;
    [_model.peoplePresenceController performFetch:&fetchError];
    if (fetchError) {
        NSLog(@"Unable to fetch people present: %@", fetchError.localizedDescription);
    }
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [self.model.payment addObserver:self forKeyPath:@"payingPerson" options:options context:PayingPersonContext];
    [self.model.payment addObserver:self forKeyPath:@"descriptionOfPayment" options:options context:DescriptionOfPaymentContext];
    [self.model.payment addObserver:self forKeyPath:@"money" options:options context:MoneyContext];
    [self.model.payment addObserver:self forKeyPath:@"categoryId" options:options context:CategoryIdContext];
    [self.model.payment addObserver:self forKeyPath:@"currency" options:NSKeyValueObservingOptionNew context:CurrencyContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.model.payment removeObserver:self forKeyPath:@"payingPerson" context:PayingPersonContext];
    [self.model.payment removeObserver:self forKeyPath:@"descriptionOfPayment" context:DescriptionOfPaymentContext];
    [self.model.payment removeObserver:self forKeyPath:@"money" context:MoneyContext];
    [self.model.payment removeObserver:self forKeyPath:@"categoryId" context:CategoryIdContext];
    [self.model.payment removeObserver:self forKeyPath:@"currency" context:CurrencyContext];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"openSelectCurrency"]) {
#ifdef DEBUG
        NSLog(@"%@, prepareForSegue openSelectCurrency", self);
#endif
        _selectCurrencyTableViewController = ChildViewStatusIsOpened;
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        SelectCurrencyTableViewController *selectCurrencyViewController = (SelectCurrencyTableViewController *)navController.viewControllers.firstObject;
        selectCurrencyViewController.currencyUpdateModel = [[PaymentUpdateCurrencyModel alloc] initWith:_model.payment];
    }
    if ([segue.identifier isEqualToString:@"selectCategory"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SelectCategoryTableViewController *destinationViewController = (SelectCategoryTableViewController *)navigationController.viewControllers.firstObject;
        [destinationViewController prepareForUseWithPayment:_model.payment];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSParameterAssert(_headerView);
    CGSize size = [_headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    if (_headerView.frame.size.height != size.height) {
        CGFloat x = _headerView.frame.origin.x;
        CGFloat y = _headerView.frame.origin.y;
        CGFloat width = _headerView.frame.size.width;
        CGFloat height = size.height;
        CGRect newFrame = CGRectMake(x, y, width, height);
        _headerView.frame = newFrame;
        self.tableView.tableHeaderView = _headerView;
    }
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)awakeFromNib {
    [super awakeFromNib];
    _selectCurrencyTableViewController = ChildViewStatusIsNotOpened;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
#ifdef DEBUG
        NSLog(@"change: %@", change);
#endif
    if (context == PayingPersonContext) {
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting: {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[MCPerson class]]) {
                    _payerNameField.text = ((MCPerson *)new).getFullName;
                    if (_model.payment.payingPerson) {
                        _payerPicture.image = _model.payment.payingPerson.picture;
                    }
                } else {
                    _payerNameField.text = nil;
                    _payerPicture.image = nil;
                }
            }
                break;
            default:
                break;
        }
    } else if (context == DescriptionOfPaymentContext) {
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting: {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[NSString class]]) {
                    _itemView.text = _model.payment.descriptionOfPayment;
                } else {
                    _itemView.text = nil;
                }
            }
                break;
            default:
                break;
        }
    } else if (context == MoneyContext) {
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting: {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[NSNumber class]]) {
                    _paidView.text = [_model.currencyFormatter stringForObjectValue:_model.payment.money];
                } else {
                    _paidView.text = nil;
                }
            }
                break;
            default:
                break;
        }
    } else if (context == CategoryIdContext) {
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting: {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[NSNumber class]]) {
                    NSArray *pictureObjects = CategoryPictureStoreController.shared.pictureObjects;
                    CategoryPictureObject *categoryObject = pictureObjects[((NSNumber *)new).shortValue];
                    if (categoryObject.categoryId > 0) {
                        _categoryView.image = categoryObject.largePicture;
                        [_categoryButton setTitle:categoryObject.categoryDescription forState:UIControlStateNormal];
                    } else {
                        NSString *buttonText = NSLocalizedString(@"Select Category", @"Select Category");
                        _categoryView.image = categoryObject.largePicture;
                        [_categoryButton setTitle:buttonText forState:UIControlStateNormal];
                    }
                } else {
                    NSArray *pictureObjects = CategoryPictureStoreController.shared.pictureObjects;
                    CategoryPictureObject *categoryObject = pictureObjects[0];
                    NSString *buttonText = NSLocalizedString(@"Select Category", @"Select Category");
                    _categoryView.image = categoryObject.largePicture;
                    [_categoryButton setTitle:buttonText forState:UIControlStateNormal];
                }
            }
                break;
            default:
                break;
        }
    } else if (context == CurrencyContext) {
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting: {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[MCCurrency class]]) {
                    _paidView.text = [_model.currencyFormatter stringForObjectValue:_model.payment.money];
                } else {
                    _paidView.text = nil;
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
