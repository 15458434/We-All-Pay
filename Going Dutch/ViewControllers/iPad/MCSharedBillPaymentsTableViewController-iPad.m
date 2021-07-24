//
//  MCSharedBillPaymentsTableViewController-iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 02-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCSharedBillPaymentsTableViewController-iPad.h"
#import "UIViewController+WeAllPayStore.h"

#import "MCWeAllPayStoreController.h"
#import "MCPayment+addons.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"

#import "MCTonightsBillTransfer.h"
#import "MCThisPaymentProtocol.h"
#import "MCDismissMeBlockProtocol.h"

#import "We_all_pay-Swift.h"

@interface MCSharedBillPaymentsTableViewController_iPad ()

@property (nonatomic, strong) NSFetchedResultsController *dataController;

@end

@implementation MCSharedBillPaymentsTableViewController_iPad

#pragma mark - New in this class

- (void)performFetch {
    NSError *error;
    BOOL success = [_dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong");
    }
}

- (void)setEmptyMessage {
    if (_dataController.fetchedObjects.count != 0) {
        [UIView animateWithDuration:1.0 animations:^{
            self.emptyMessage.bigMessage.alpha = 0.0;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        } completion:nil];
    } else {
        if (_emptyMessage.bigMessage.alpha < 1.0) {
            [UIView animateWithDuration:1.0 animations:^{
                self.emptyMessage.bigMessage.alpha = 1.0;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            } completion:nil];
        }
    }
}

- (void)setEmptyMessageNow {
    if (_dataController.fetchedObjects.count != 0) {
        [UIView animateWithDuration:0.0 animations:^{
            self.emptyMessage.bigMessage.alpha = 0.0;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        } completion:nil];
    } else {
        if (_emptyMessage.bigMessage.alpha < 1.0) {
            [UIView animateWithDuration:0.0 animations:^{
                self.emptyMessage.bigMessage.alpha = 1.0;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            } completion:nil];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
            break;
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}

#pragma mark - UITableViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataController.fetchedObjects.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPayment *thisCellsPayment = [_dataController objectAtIndexPath:indexPath];
    PaymentTableViewCell_iPad *thisCell = [tableView dequeueReusableCellWithIdentifier:@"MCPaymentTableViewCell_iPad"];
    thisCell.accessibilityIdentifier = [NSString stringWithFormat:@"PaymentTableViewCell-%lu", indexPath.row];
    
    NSString *thisCellsPayerName;
    if ([thisCellsPayment payingPerson]) {
        thisCellsPayerName = [[thisCellsPayment payingPerson] getFullName];
    } else {
        thisCellsPayerName = NSLocalizedString(@"THISPAYMENTCELL_NOPAYERNAME", @"Someone");
    }
    thisCell.namePayerLabel.text = thisCellsPayerName;
    
    // Get category picture.
    NSArray *pictureObjects = CategoryPictureStoreController.shared.pictureObjects;
    CategoryPictureObject *categoryObject = pictureObjects[thisCellsPayment.categoryId.shortValue];
    thisCell.pictureOfPayer.image = categoryObject.smallPicture;
    
    NSString *thisCellsDescriptionOfPayment = [thisCellsPayment descriptionOfPayment];
    if (!thisCellsDescriptionOfPayment) {
        thisCellsDescriptionOfPayment = NSLocalizedString(@"THISPAYMENTCELL_NOOBJECT", @"Something");
    }
    thisCell.whatPaidLabel.text = thisCellsDescriptionOfPayment;
    
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:thisCellsPayment.currency.code];
    thisCell.moneyPaidLabel.text = [cf stringForObjectValue:thisCellsPayment.money];
    
    return thisCell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [WhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:_tonightsBill];
        [MCPayment deletePayment:[_dataController objectAtIndexPath:indexPath]];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return [[self tableView] isEditing];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"openPayment" sender:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startRespondingToStoreChangeNotifications];
    
    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage_iPad" owner:self options:nil][0];
    _emptyMessage.bigMessage.text = NSLocalizedString(@"EMPTY_PAYMENT_LIST_MESSAGE", @"Press \"add payment\" to add a payment to this event.");
    _emptyMessage.bigMessage.alpha = 0.0;
    self.tableView.backgroundView = _emptyMessage;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Get tonightsBill from parentViewController
    id myParent = [self parentViewController];
    if ([myParent conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
        _tonightsBill = [myParent tonightsBill];
    }
    
    if (!_dataController) {
        _dataController = [[MCWeAllPayStoreController defaultStore] sharedBillPaymentsDataControllerForDelegate:self];
    }
    [self performFetch];
    [[self tableView] reloadData];
    [self setEmptyMessageNow];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"openPayment"]) {
        UINavigationController *navController = segue.destinationViewController;
        if (@available(iOS 13.0, *)) {
            navController.modalInPresentation = YES;
        }
        PaymentViewController *destination = (PaymentViewController *)navController.viewControllers.firstObject;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destination.thisPayment = [_dataController objectAtIndexPath:indexPath];
        destination.tonightsBill = _tonightsBill;
        [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
