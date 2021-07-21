//
//  MCPeopleViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCEditTripViewController.h"
#import "MCPersonViewController.h"
#import "MCSharedBillTableViewController.h"
#import "MCSharedBillPageViewController.h"
#import "UIViewController+WeAllPayStore.h"

#import "MCWeAllPayStoreController.h"
#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCCurrency+addons.h"

#import "We_all_pay-Swift.h"

@interface MCEditTripViewController ()

@property (strong, nonatomic) MCTableEmptyMessage *emptyMessage;

@property (weak, nonatomic) IBOutlet UITableViewHeaderFooterView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *tripNameField;
@property (weak, nonatomic) IBOutlet UIButton *addPersonButton;
@property (weak, nonatomic) IBOutlet UIButton *contactsButton;

@property (nonatomic, strong) NSFetchedResultsController *dataController;
@property (nonatomic, strong) ContactsDataReceiver *contactsInserter;

@end

@implementation MCEditTripViewController

- (IBAction)addressBookButton:(id)sender {
    if (!_contactsInserter) {
        _contactsInserter = [[ContactsDataReceiver alloc] initWith:_tonightsBill];
    }
    [_contactsInserter presentContactsPickerWith:self completion:nil];
}


- (IBAction)addPersonButton:(id)sender {
    if (_tripNameField.isEditing) {
        [_tripNameField resignFirstResponder];
    }
}

- (void)tappedInTheBackground:(id)sender {
    [_tripNameField resignFirstResponder];
}

- (void)performFetch {
    NSError *error;
    BOOL success = [_dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong: %@", error);
    }
}

- (void)setEmptyMessageWithDuration:(NSTimeInterval)duration {
    if (_dataController.fetchedObjects.count != 0) {
        if (_emptyMessage.bigMessage.alpha > 0.0) {
            [UIView animateWithDuration:duration animations:^{
                self.emptyMessage.bigMessage.alpha = 0.0;
                self.emptyMessage.borderlineView.alpha = 0.0;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            } completion:nil];
        }
    } else {
        if (_emptyMessage.bigMessage.alpha < 1.0) {
            [UIView animateWithDuration:duration animations:^{
                self.emptyMessage.bigMessage.alpha = 1.0;
                self.emptyMessage.borderlineView.alpha = 1.0;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            } completion:nil];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _tonightsBill.tripName = _tripNameField.text;
    NSDate *now = [NSDate date];
    _tonightsBill.dateModified = now;
    [MCWeAllPayStoreController.defaultStore saveMainThreadContext];
    if (!_didSomethingChange) {
        _didSomethingChange = YES;
    }
    MCPerson *nextPayer = [[_tonightsBill fetchPeoplePresentOrderedByAmountPaid:YES] firstObject];

    WhoPayingUserDefaultsStoreInterface *groupStore = [[WhoPayingUserDefaultsStoreInterface alloc] initWithTonightsBillUUID:_tonightsBill.uniqueBillId tripName:_tonightsBill.tripName nextPayerUUID:nextPayer.uniquePersonId fullNameOfNextPayer:[nextPayer getFullName]];
    [groupStore storeToDefaults];
    [[NCWidgetController widgetController] setHasContent:YES forWidgetWithBundleIdentifier:[WhoPayingUserDefaultsStoreInterface MCWhoIsPayingNextBundleIdentifier]];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self setEmptyMessageWithDuration:1.0];
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            _didSomethingChange = YES;
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark - UITableViewController

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPerson *thisCellsPerson = [_dataController objectAtIndexPath:indexPath];
    MCPersonTableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:@"MCPersonTableViewCell"];
    
    [[thisCell personImage] setImage:[thisCellsPerson thumbnail]];
    [[thisCell nameLabel] setText:[thisCellsPerson getFullName]];
    [[thisCell emailLabel] setText:[thisCellsPerson defaultEmailAddress]];
    
    if (![thisCellsPerson hasPersonMadePaymentWithInvalidExchangeRates]) {
        [thisCell.fetchingExchangeRateIndicator stopAnimating];
        [[thisCell totalSpent] setHidden:NO];
        
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
        thisCell.totalSpent.text = [cf stringForObjectValue:thisCellsPerson.totalSumPaid];
    } else {
        [thisCell.fetchingExchangeRateIndicator startAnimating];
        [[thisCell totalSpent] setHidden:YES];
    }

    
    return thisCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self tableView] isEditing]) {
        MCPerson *person = [_dataController objectAtIndexPath:indexPath];
        if ([_tonightsBill hasPersonPaidSomething:person]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCPerson *removablePerson = [_dataController objectAtIndexPath:indexPath];
        [_tonightsBill deletePerson:removablePerson];
        [MCWeAllPayStoreController.defaultStore saveMainThreadContext];
        _didSomethingChange = YES;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"openEditPerson" sender:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self startRespondingToStoreChangeNotifications];
    
    _emptyMessage = [NSBundle.mainBundle loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    self.tableView.backgroundView = _emptyMessage;
    _emptyMessage.topConstraint.constant = _headerView.frame.size.height;
    _emptyMessage.bigMessage.text = NSLocalizedString(@"PEOPLE_LIST_EMPTY_MESSAGE", @"Press \"add Person\" to add a person who you'd like to share this bill with.");
    [self setEmptyMessageWithDuration:0.0];
    
    // Make sure a tap in the background dismisses the keyboard as well.
    UITapGestureRecognizer *thatTickles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInTheBackground:)];
    thatTickles.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:thatTickles];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _tripNameField.text = _tonightsBill.tripName;
    _tripNameField.delegate = self;
    
    if (!_dataController) {
        _dataController = [MCWeAllPayStoreController.defaultStore sharedBillPeoplePresentDataControllerForDelegate:self];
        [self performFetch];
        [self.tableView reloadData];
    }
    
    BOOL shouldAppearAsEditing = [_myParent isChildTableViewEditing];
    [self.tableView setEditing:shouldAppearAsEditing animated:NO];

    [self setEmptyMessageWithDuration:0.0];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _dataController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"openEditPerson"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        if (@available(iOS 13.0, *)) {
            navController.modalInPresentation = YES;
        }
        MCPersonViewController *destination = navController.viewControllers.firstObject;
        destination.isAdBannerEnabled = YES;
        NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
        MCPerson *thePerson = [_dataController objectAtIndexPath:indexPathOfSelectedRow];
        [MCWeAllPayStoreController.defaultStore beginUndoGroup];
        if (!thePerson) {
            // No person present create a new one.
            thePerson = [_tonightsBill addPerson];
            [thePerson setThumbnailDataFromImage:nil];
            [thePerson setPictureDataFromImage:nil];
            destination.thisPerson = thePerson;
            destination.isNew = YES;
        } else {
            // Person present open it.
            destination.thisPerson = thePerson;
            destination.isNew = NO;
            [self.tableView deselectRowAtIndexPath:indexPathOfSelectedRow animated:YES];
        }
    } else {
        NSString *reason = [NSString stringWithFormat:@"Invalid segue.identifier: %@", segue.identifier];
        NSDictionary *userInfo = [segue dictionaryWithValuesForKeys:@[@"source", @"destimation", @"identifier"]];
        @throw [NSException exceptionWithName:@"segue identifiter" reason:reason userInfo:userInfo];
    }
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
