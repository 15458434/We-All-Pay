//
//  MCSharedBillTableViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;
@import WhoPayingUserDefaultsStoreInterface;

#import "MCSharedBillTableViewController.h"
#import "UIViewController+WeAllPayStore.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"

#import "MCGenericInterstitialAdTableViewController.h"
#import "MCAllTripsTableViewController.h"
#import "MCEditTripViewController.h"
#import "MCPaymentViewController.h"
#import "MCReturnPaymentViewController.h"
#import "MCSharedBillPageViewController.h"
#import "MCSharedBillMainViewController.h"

#import "We_all_pay-Swift.h"

@interface MCSharedBillTableViewController () <ShowPayment>

@property (weak, nonatomic) IBOutlet MCTableEmptyMessage *headerView;

@property (nonatomic, strong) NSFetchedResultsController *dataController;
@property (nonatomic, strong) MCPayment *forOpenPaymentWithMissingDataForSegue;

@end

@implementation MCSharedBillTableViewController

#pragma mark - Actions

- (IBAction)addPaymentPressed:(id)sender {
    if (_tonightsBill.peoplePresent.count == 0) {
        NSString *title = NSLocalizedString(@"Add some people first", @"Title for an alert message, because there are no people added to this event.");
        NSString *message = NSLocalizedString(@"You can't add a payment when no people are present. There is no one to split the expenses among.", @"A message to the user thay can't add a payment when they didn't add people to the even.");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        NSString *cancelActionTitle = NSLocalizedString(@"Cancel", @"Text on button to cancel something");
        [alertController addAction:[UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [self performSegueWithIdentifier:@"openPaymentView" sender:self];
}

- (IBAction)solveButtonPressed:(id)sender {
    if (_tonightsBill.peoplePresent.count == 0) {
        NSString *title = NSLocalizedString(@"Add some people first", @"Title for an alert message, because there are no people added to this event.");
        NSString *message = NSLocalizedString(@"You can't add a payment when no people are present. There is no one to split the expenses among.", @"A message to the user thay can't add a payment when they didn't add people to the even.");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        NSString *cancelActionTitle = NSLocalizedString(@"Cancel", @"Text on button to cancel something");
        [alertController addAction:[UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    // Check for all payers present.
    if ([_tonightsBill doAllPaymentHaveAPayer]) {
        // perform segue
        [self performSegueWithIdentifier:@"solveButton" sender:self];
    } else {
        // Give user alert.
        NSString *title = NSLocalizedString(@"UNABLE_TO_SOLVE", @"Unable to solve");
        NSString *message = NSLocalizedString(@"At least one of the payments is missing a payer.", @"One of the payments is missing a payer.");
        NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"Text on button to cancel something");
        NSString *fixItButtonTitle = NSLocalizedString(@"Go to", @"Go to");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:fixItButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self openFirstPaymentWithoutAPayer];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)dismissEdit:(id)selector {

}

#pragma mark - New in this class.

- (void)prepareDataControllerAndFetch
{
    _dataController = [[MCWeAllPayStoreController defaultStore] sharedBillPaymentsDataControllerForDelegate:self];
    NSError *error;
    BOOL success = [_dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong fetching the payments");
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

- (void)openFirstPaymentWithoutAPayer
{
    // This opens the payment detail view with the first payment on the tonightsBill which, doesn't have a payer.
    [self performSegueWithIdentifier:@"openFirstPaymentWithoutPayer" sender:self];
}

#pragma mark - NSNotification

- (void)writableTonightsBillIsCreated:(NSNotification *)notification
{
    // Should be executed on the background thread.
    NSDictionary *userInfo = [notification userInfo];
    _writableTonightsBill = [userInfo objectForKey:MCwritableTonightsBillKey];
    NSLog(@"WritableTonightsBillIsCreated has been executed.");
}

#pragma mark - ShowPayment

- (void)show:(MCPayment *)payment
{
    [self performSegueWithIdentifier:@"openPaymentWithMissingData" sender:self];
}

#pragma mark - MFMailViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultCancelled) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSent) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
        [[NCWidgetController widgetController] setHasContent:NO forWidgetWithBundleIdentifier:WhoPayingUserDefaultsStoreInterface.MCWhoIsPayingNextBundleIdentifier];
    } else if (result == MFMailComposeResultSaved) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"Something went wrong: %@", error);
    }
}
    
#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessageWithDuration:1.0];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessageWithDuration:1.0];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark - UITableViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataController.sections[section].numberOfObjects;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataController.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPayment *thisCellsPayment = [_dataController objectAtIndexPath:indexPath];
    if (!thisCellsPayment) {
    }
    MCPaymentTableViewCell *paymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCPaymentTableViewCell"];
    
    NSString *thisCellsPayerName;
    if ([thisCellsPayment payingPerson]) {
        thisCellsPayerName = thisCellsPayment.payingPerson.getFullName;
    } else {
        thisCellsPayerName = NSLocalizedString(@"THISPAYMENTCELL_NOPAYERNAME", @"Someone");
    }
    paymentCell.namePayerLabel.text = thisCellsPayerName;
    
    // Get category picture.
    NSArray *pictureObjects = CategoryPictureStoreController.shared.pictureObjects;
    CategoryPictureObject *categoryObject = pictureObjects[thisCellsPayment.categoryId.shortValue];
    paymentCell.itemTypeImageView.image = categoryObject.smallPicture;
    
    NSString *thisCellsDescriptionOfPayment = [thisCellsPayment descriptionOfPayment];
    if (!thisCellsDescriptionOfPayment) {
        thisCellsDescriptionOfPayment = NSLocalizedString(@"THISPAYMENTCELL_NOOBJECT", @"Something");
    }
    paymentCell.whatPaidLabel.text =thisCellsDescriptionOfPayment;
    
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:thisCellsPayment.currency.code];
    paymentCell.moneyPaidLabel.text = [cf stringForObjectValue:thisCellsPayment.money];
    
    return paymentCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCPayment *toBeDeletedPayment = [_dataController objectAtIndexPath:indexPath];
        [MCPayment deletePayment:toBeDeletedPayment];
        [WhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:_tonightsBill];
        [MCWeAllPayStoreController.defaultStore.mainThreadContext processPendingChanges];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.isEditing ? YES : NO;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"openPaymentView" sender:self];
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    _emptyMessage.borderlineView.dyInset = 1;
    self.tableView.backgroundView = _emptyMessage;
    _emptyMessage.bigMessage.text = NSLocalizedString(@"EMPTY_PAYMENT_LIST_MESSAGE", @"Press \"add payment\" to add a payment to this event.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self startRespondingToStoreChangeNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (!_dataController) {
        [self prepareDataControllerAndFetch];
        [[self tableView] reloadData];
        [self setEmptyMessageWithDuration:0.0];
    }
    
    BOOL shouldAppearAsEditing = [_myParent isChildTableViewEditing];
    [[self tableView] setEditing:shouldAppearAsEditing animated:NO];
    
    _emptyMessage.topConstraint.constant = self.headerView.frame.size.height;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[self view] endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _dataController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openFirstPaymentWithoutPayer"]) {
        NSParameterAssert([[[segue destinationViewController] viewControllers][0] conformsToProtocol:@protocol(MCThisPaymentProtocol)]);
        id<MCThisPaymentProtocol, MCTonightsBillTransfer> theDestination = [[segue destinationViewController] viewControllers][0];
        [theDestination setThisPayment:[_tonightsBill getFirstPaymentWithoutAPayer]];
        [theDestination setTonightsBill:_tonightsBill];
        if (@available(iOS 13.0, *)) {
            UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
            navController.modalInPresentation = YES;
        }
    } else if ([segue.identifier isEqualToString:@"openPaymentWithMissingData"]) {
        NSParameterAssert([[[segue destinationViewController] viewControllers][0] conformsToProtocol:@protocol(MCThisPaymentProtocol)]);
        id<MCThisPaymentProtocol, MCTonightsBillTransfer> theDestination = [[segue destinationViewController] viewControllers][0];
        [theDestination setTonightsBill:_tonightsBill];
        [theDestination setThisPayment:_forOpenPaymentWithMissingDataForSegue];
        _forOpenPaymentWithMissingDataForSegue = nil;
        if (@available(iOS 13.0, *)) {
            UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
            navController.modalInPresentation = YES;
        }
    } else if ([segue.identifier isEqualToString:@"openPaymentView"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        if (@available(iOS 13.0, *)) {
            navController.modalInPresentation = YES;
        }
        MCPayment *payment;
        NSIndexPath *indexPathOfSelectedRow = self.tableView.indexPathForSelectedRow;
        if (indexPathOfSelectedRow) {
            [self.tableView deselectRowAtIndexPath:indexPathOfSelectedRow animated:YES];
            payment = [_dataController objectAtIndexPath:indexPathOfSelectedRow];
        }
        MCPaymentViewController *paymentViewController = (MCPaymentViewController *)navController.viewControllers[0];
        paymentViewController.thisPayment = payment;
        paymentViewController.tonightsBill = _tonightsBill;
    } else if ([segue.identifier isEqualToString:@"solveButton"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        SolutionViewController *destination = navController.viewControllers.firstObject;
        [destination updateEvent:_tonightsBill andSendMailDelegate:_mailDelegate andAdEngine:self.adEngine];
    } else {
        NSLog(@"Unknown segue with identifier: %@", segue.identifier);
        NSParameterAssert(NO);
    }
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
