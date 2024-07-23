//
//  MCPaymentsTableViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;
@import WhoPayingUserDefaultsStoreInterface;

#import "MCPaymentsTableViewController.h"
#import "UIViewController+WeAllPayStore.h"

#import "MCSharedBill+addons.h"
#import "MCPerson+CoreDataProperties.h"
#import "MCPayment+CoreDataProperties.h"

#import "MCAllTripsTableViewController.h"
#import "MCEditTripViewController.h"
#import "MCPaymentViewController.h"
#import "MCReturnPaymentViewController.h"
#import "MCSharedBillPageViewController.h"
#import "MCSharedBillMainViewController.h"

#import "We_all_pay-Swift.h"

static void * isEditingToggleContext = &isEditingToggleContext;

@interface MCPaymentsTableViewController () <ShowPayment>

@property (weak, nonatomic) IBOutlet UIButton *addPaymentButton;
@property (weak, nonatomic) IBOutlet UIButton *solveEventButton;

@property (weak, nonatomic) IBOutlet MCTableEmptyMessage *headerView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MCPayment *forOpenPaymentWithMissingDataForSegue;

@end

@implementation MCPaymentsTableViewController

#pragma mark - Actions

- (IBAction)addPaymentTouchUpInside:(UIButton *)sender {
    if (_eventModel.amountOfPeoplePresentOnEvent == 0) {
        [self showNoPeoplePresentAlert];
        return;
    }
    
    UIUserInterfaceSizeClass horizontalSizeClass = self.traitCollection.horizontalSizeClass;
    UIUserInterfaceSizeClass verticalSizeClass = self.traitCollection.verticalSizeClass;
    if (horizontalSizeClass == UIUserInterfaceSizeClassRegular && verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        [self performSegueWithIdentifier:@"newPayment_iPad" sender:self];
    } else {
        [self performSegueWithIdentifier:@"openPaymentView" sender:self];
    }
}

- (IBAction)solveEventButtonTouchUpInside:(UIButton *)sender {
    if (_eventModel.amountOfPeoplePresentOnEvent == 0) {
        [self showNoPeoplePresentAlert];
        return;
    }
    
    // Check for all payers present.
    if ([_eventModel doAllPaymentsHaveAPayer]) {
        // perform segue
        [self performSegueWithIdentifier:@"solveButton" sender:self];
    } else {
        // Give user alert.
        NSString *title = NSLocalizedStringWithDefaultValue(@"payments_view_alert_title_cannot_solve", nil, NSBundle.mainBundle, @"Unable to solve", @"Title of an alert shown to the user when solve has been pressed the We All Pay is unable to solve due to a missing payer on an payment.");
        NSString *message = NSLocalizedStringWithDefaultValue(@"payments_view_alert_message_cannot_solve", nil, NSBundle.mainBundle, @"One of the payments is missing information on who paid it", @"Message of an alert shown to the user when solve has been pressed and We All Pay is unable to solve due to a missing payer on a payment.");
        NSString *cancelButtonTitle = NSLocalizedStringWithDefaultValue(@"payments_view_alert_cancel", nil, NSBundle.mainBundle, @"Cancel", @"Text on a button to press the cancel action on an alert that tells the user the current event can't be solved due to missing information on who paid something.");
        NSString *fixItButtonTitle = NSLocalizedStringWithDefaultValue(@"payments_view_alert_go_to", nil, NSBundle.mainBundle, @"Open Payment", @"Button on an alert that navigates the payment that's missing the information who paid that particular payment");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:fixItButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self openFirstPaymentWithoutAPayer];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)dismissEdit:(id)selector {

}

#pragma mark - New in this class.

- (void)showNoPeoplePresentAlert {
    NSString *title = NSLocalizedStringWithDefaultValue(@"payments_view_alert_title_add_people_first", nil, NSBundle.mainBundle, @"Add some people first", @"Title for an alert message, because there are no people added to this event.");
    NSString *message = NSLocalizedStringWithDefaultValue(@"payments_view_message_add_people_first", nil, NSBundle.mainBundle, @"You can't add a payment when no people are present. There is no one to split the expenses of this event with.", @"A message to the user they can't add a payment when they didn't add people to the event.");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    NSString *cancelActionTitle = NSLocalizedStringWithDefaultValue(@"payments_view_alert_button_dismiss", nil, NSBundle.mainBundle, @"Dismiss", @"Text for button on an alert that dismisses the alert");
    [alertController addAction:[UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)prepareDataControllerAndFetch {
    _fetchedResultsController = _eventModel.paymentsFetchedResultsController;
    _fetchedResultsController.delegate = self;
    NSError *error;
    BOOL success = [_fetchedResultsController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong fetching the payments");
    }
}

- (void)setEmptyMessageWithDuration:(NSTimeInterval)duration {
    if (_fetchedResultsController.fetchedObjects.count != 0) {
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

- (void)openFirstPaymentWithoutAPayer {
    // This opens the payment detail view with the first payment on the tonightsBill which, doesn't have a payer.
    UIUserInterfaceSizeClass horizontalSizeClass = self.traitCollection.horizontalSizeClass;
    UIUserInterfaceSizeClass verticalSizeClass = self.traitCollection.verticalSizeClass;
    if (horizontalSizeClass == UIUserInterfaceSizeClassRegular && verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        [self performSegueWithIdentifier:@"openFirstPaymentWithoutPayer_iPad" sender:self];
    } else {
        [self performSegueWithIdentifier:@"openFirstPaymentWithoutPayer" sender:self];
    }
}

#pragma mark - NSNotification

#pragma mark - ShowPayment

- (void)show:(MCPayment *)payment {
    UIUserInterfaceSizeClass horizontalSizeClass = self.traitCollection.horizontalSizeClass;
    UIUserInterfaceSizeClass verticalSizeClass = self.traitCollection.verticalSizeClass;
    if (horizontalSizeClass == UIUserInterfaceSizeClassRegular && verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        [self performSegueWithIdentifier:@"openPaymentWithMissingData_iPad" sender:self];
    } else {
        [self performSegueWithIdentifier:@"openPaymentWithMissingData" sender:self];
    }
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessageWithDuration:1.0];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessageWithDuration:1.0];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - UITableViewController

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPayment *payment = [_fetchedResultsController objectAtIndexPath:indexPath];
    MCPaymentTableViewCell *paymentCell = (MCPaymentTableViewCell *)cell;
    [paymentCell updateWithPayment:payment];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIUserInterfaceSizeClass horizontalSizeClass = self.traitCollection.horizontalSizeClass;
    UIUserInterfaceSizeClass verticalSizeClass = self.traitCollection.verticalSizeClass;
    if (horizontalSizeClass == UIUserInterfaceSizeClassRegular && verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        [self performSegueWithIdentifier:@"openPayment_iPad" sender:self];
    } else {
        [self performSegueWithIdentifier:@"openPaymentView" sender:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fetchedResultsController.sections[section].numberOfObjects;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _fetchedResultsController.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPaymentTableViewCell *paymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCPaymentTableViewCell"];
    return paymentCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCPayment *toBeDeletedPayment = [_fetchedResultsController objectAtIndexPath:indexPath];
        [_eventModel deletePayment:toBeDeletedPayment];
        [WhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:_eventModel.event];
        [WeAllPayStoreController.defaultStore.viewContext processPendingChanges];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.isEditing ? YES : NO;
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    NSString *addPaymentButtonTitle = NSLocalizedStringWithDefaultValue(@"payments_view_button_add_payment", nil, NSBundle.mainBundle, @"Add payment", @"Title of a button that adds a payment and opens the new payment view to enter the information on a new payment");
    UIFont *font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    NSDictionary<NSAttributedStringKey,id> *attrs = @{NSFontAttributeName: font};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:addPaymentButtonTitle attributes:attrs];
    [_addPaymentButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    
    NSString *solveEventButtonTitle = NSLocalizedStringWithDefaultValue(@"payments_view_button_solve_event", nil, NSBundle.mainBundle, @"Solve", @"Title of a button that solves who needs to pay whom on the current event.");
    NSAttributedString *attributedsolveEventButtonTitle = [[NSAttributedString alloc] initWithString:solveEventButtonTitle attributes:attrs];
    [_solveEventButton setAttributedTitle:attributedsolveEventButtonTitle forState:UIControlStateNormal];
    
    self.tableView.accessibilityIdentifier = @"PaymentsTableViewController";
    
    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    _emptyMessage.borderlineView.dxInset = 20;
    _emptyMessage.borderlineView.dyInset = 1;
    self.tableView.backgroundView = _emptyMessage;
    _emptyMessage.bigMessage.text = NSLocalizedStringWithDefaultValue(@"payments_view_label_empty_list", nil, NSBundle.mainBundle, @"Press \"Add payment\" to add a payment to this event.", @"Empty message list for when the list of payments is empty and there are no payments on the current event");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startRespondingToStoreChangeNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (!_fetchedResultsController) {
        [self prepareDataControllerAndFetch];
        [[self tableView] reloadData];
        [self setEmptyMessageWithDuration:0.0];
    }
    
    _emptyMessage.topConstraint.constant = self.headerView.frame.size.height;
    
    // Create KVO
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [self.isEditingModel addObserver:self forKeyPath:@"boolValue" options:options context:isEditingToggleContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[self view] endEditing:YES];
    
    _fetchedResultsController = nil;
    
    // Destroy KVO
    [self.isEditingModel removeObserver:self forKeyPath:@"boolValue" context:isEditingToggleContext];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _fetchedResultsController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openFirstPaymentWithoutPayer"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        MCPaymentViewController *destination = (MCPaymentViewController *)navigationController.viewControllers[0];
        [destination prepareForUseWithPayment:_eventModel.firstPaymentWithoutAPayer];
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        navController.modalInPresentation = YES;
    } else if ([segue.identifier isEqualToString:@"openPaymentWithMissingData"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        MCPaymentViewController *destination = (MCPaymentViewController *)navigationController.viewControllers[0];
        [destination prepareForUseWithPayment:_forOpenPaymentWithMissingDataForSegue];
        _forOpenPaymentWithMissingDataForSegue = nil;
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        navController.modalInPresentation = YES;
    } else if ([segue.identifier isEqualToString:@"openPaymentView"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        navController.modalInPresentation = YES;
        MCPayment *payment;
        NSIndexPath *indexPathOfSelectedRow = self.tableView.indexPathForSelectedRow;
        if (indexPathOfSelectedRow) {
            [self.tableView deselectRowAtIndexPath:indexPathOfSelectedRow animated:YES];
            payment = [_fetchedResultsController objectAtIndexPath:indexPathOfSelectedRow];
        }
        MCPaymentViewController *paymentViewController = (MCPaymentViewController *)navController.viewControllers[0];
        if (!payment) {
            [paymentViewController prepareForUseWithEventModel:_eventModel];
        } else {
            [paymentViewController prepareForUseWithPayment:payment];
        }
    } else if ([segue.identifier isEqualToString:@"solveButton"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        SolutionViewController *destination = navController.viewControllers.firstObject;
        [destination updateEvent:_eventModel.event andSendMailDelegate:_mailDelegate];
    } else if ([segue.identifier isEqualToString:@"openFirstPaymentWithoutPayer_iPad"]) {
        NSParameterAssert([[[segue destinationViewController] viewControllers][0] conformsToProtocol:@protocol(MCThisPaymentProtocol)]);
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        PaymentViewController *destination = (PaymentViewController *)navigationController.viewControllers[0];
        MCPayment *payment = _eventModel.firstPaymentWithoutAPayer;
        if (payment) {
            [destination prepareForUseWithPayment:payment];
        } else {
            [destination prepareForUseWithEventModel:_eventModel];
        }
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        navController.modalInPresentation = YES;
    } else if ([segue.identifier isEqualToString:@"openPaymentWithMissingData_iPad"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        PaymentViewController *destination = navigationController.viewControllers[0];
        [destination prepareForUseWithPayment:_forOpenPaymentWithMissingDataForSegue];
        _forOpenPaymentWithMissingDataForSegue = nil;
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        navController.modalInPresentation = YES;
    } else if ([segue.identifier isEqualToString:@"newPayment_iPad"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        navController.modalInPresentation = YES;
        PaymentViewController *destination = (PaymentViewController *)navController.viewControllers.firstObject;
        [destination prepareForUseWithEventModel:_eventModel];
    } else if ([segue.identifier isEqualToString:@"openPayment_iPad"]) {
        UINavigationController *navController = segue.destinationViewController;
        navController.modalInPresentation = YES;
        PaymentViewController *destination = (PaymentViewController *)navController.viewControllers.firstObject;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MCPayment *payment = [_fetchedResultsController objectAtIndexPath:indexPath];
        [destination prepareForUseWithPayment:payment];
        [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        NSLog(@"Unknown segue with identifier: %@", segue.identifier);
        NSParameterAssert(NO);
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

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == &isEditingToggleContext) {
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
                    NSNumber *isEditing = (NSNumber *)new;
                    [self.tableView setEditing:isEditing.boolValue animated:YES];
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
