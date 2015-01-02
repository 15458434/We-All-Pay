//
//  MCPaymentTableViewController_iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 06-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentTableViewController_iPad.h"
#import "MCSelectPayerTableViewController_iPad.h"
#import "UINavigationController+KeyboardDismiss.h"
#import "MCSelectCurrencyTableViewController_iPad.h"

#import "MCPaymentPresenceTableViewCell.h"

#import "MCThisPaymentProtocol.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCpaymentPresence+addons.h"

#import "MCCategoryPictureStoreController.h"
#import "MCCategoryPictureObject.h"

#import "MCWhoPayingUserDefaultsStoreInterface+WeAllPay.h"

@interface MCPaymentTableViewController_iPad ()

@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIImageView *payerView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end

@implementation MCPaymentTableViewController_iPad

#pragma mark - Actions

- (IBAction)mainCancelPressed:(id)sender
{
    _mainCancelPressed = cancelIsPressed;
    _dataController.delegate = nil;
    if ([[[[MCWeAllPayStoreController defaultStore] mainThreadContext] undoManager] canUndo]) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    if (_dismissMe) {
        _dismissMe();
    }
}

- (IBAction)mainDonePressed:(id)sender
{
    NSDate *now = [NSDate date];
    [_tonightsBill setDateModified:now];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    [MCWhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:_tonightsBill];
    
    if (_dismissMe) {
        _dismissMe();
    }
}

- (IBAction)itemValueChanged:(id)sender
{

}

- (IBAction)moneyValueChanged:(id)sender
{

}

- (IBAction)dismissKeyboardWhenTappedOutsideAUITextField:(id)sender
{
    [self dismissTheKeyboard];
}

#pragma mark - New in this class

- (void)reloadCategoryImageView
{
    // Put the correct category symbol on the categoryButton.
    MCCategoryPictureObject *categoryObject = [[[MCCategoryPictureStoreController sharedController] pictureObjects] objectAtIndex:[_thisPayment.categoryId shortValue]];
    if ([categoryObject categoryId] > 0) {
        _categoryImage.image = categoryObject.largePicture;
    } else {
        _categoryImage.image = nil;

    }
}

- (void)setTextForCategoryButton
{
    // Put the correct category symbol on the categoryButton.
    MCCategoryPictureObject *categoryObject = [[[MCCategoryPictureStoreController sharedController] pictureObjects] objectAtIndex:[_thisPayment.categoryId shortValue]];
    if ([categoryObject categoryId] > 0) {
        _categoryImage.image = categoryObject.largePicture;
        [_categoryButton setTitle:categoryObject.categoryDescription forState:UIControlStateNormal];
    } else {
        _categoryImage.image = nil;
        NSString *title = NSLocalizedString(@"SELECT_CATEGORY", @"Text of the category button.");
        [_categoryButton setTitle:title forState:UIControlStateNormal];
    }
    [_categoryButton sizeToFit];
}

- (void)performFetchAndReloadTableView:(NSNotification *)notification
{
    UIManagedDocument *weAllPayDocument = [[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument];
    if ([weAllPayDocument documentState] == UIDocumentStateNormal) {
        [self performFetch];
        [[self tableView] reloadData];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)performFetch
{
    NSError *error;
    BOOL success = [_dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong");
    }
}


- (void)reloadPayerView
{
    [self setTextPayerButton];
    if ([[_thisPayment payingPerson] picture]) {
        _payerView.image = _thisPayment.payingPerson.picture;
    } else {
        _payerView.image = nil;
    }
}

- (void)setTextPayerButton
{
    [_selectButton setTitle:[_thisPayment.payingPerson getFullName] forState:UIControlStateNormal];
    [_selectButton sizeToFit];
}

- (void)tappedInTheBackground:(id)selector
{
    [self dismissTheKeyboard];
}

#pragma mark - Inherited from super

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // _tonightsBill should be present.
    NSParameterAssert(_tonightsBill);
    
//    _didSomethingChange = MCNothingHasChanged;
    _mainCancelPressed = cancelIsNotPressed;
    [[MCWeAllPayStoreController defaultStore] beginUndoGroup];
    
    // Make sure a tap in the background dimisses the keyboard as well.
    UITapGestureRecognizer *thatTickles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInTheBackground:)];
    [thatTickles setCancelsTouchesInView:NO];
    [[self tableView] addGestureRecognizer:thatTickles];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!_thisPayment) {
        _thisPayment = [_tonightsBill addPayment];
//        _didSomethingChange = MCSomethingHasChanged;
        _isNew = isNew;
        NSString *newTitle = NSLocalizedString(@"NEW_PAYMENT_HEADER", "new payment");
        [self setTitle:newTitle];
    } else {
        [itemField setText:[_thisPayment descriptionOfPayment]];
        if ([_thisPayment money]) {
            [paidField setText:[_thisPayment getMoneyValueInCurrencyAsAString]];
        }
        [self reloadPayerView];
        [self setTextPayerButton];
        _isNew = isNotNew;
    }
    
    [self reloadCategoryImageView];
    [self setTextForCategoryButton];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"person.firstName" ascending:YES];
    _paymentPresenceArray = [[_thisPayment peopleSharingPayment] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    if (!_dataController) {
        _dataController = [[MCWeAllPayStoreController defaultStore] paymentPresenceDataControllerForDelegate:self];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    if (isNew) {
//        [tracker set:kGAIScreenName value:@"MCPaymentNewView_iPad"];
//    } else {
//        [tracker set:kGAIScreenName value:@"MCPaymentDetailsView_iPad"];
//    }
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _dataController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MCDismissKeyboardProtocol

- (void)dismissTheKeyboard
{
    if ([itemField isFirstResponder]) {
        [itemField resignFirstResponder];
    } else if ([paidField isFirstResponder]) {
        [paidField resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == paidField) {
        if ([[_thisPayment money] compare:@0.005] == NSOrderedAscending) {
            [paidField setText:@""];
        } else {
            [paidField setText:[_thisPayment getMoneyValueAsAString]];
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_mainCancelPressed == cancelIsNotPressed) {
        if (textField == itemField) {
            [_thisPayment setDescriptionOfPayment:[itemField text]];
//            _didSomethingChange = MCSomethingHasChanged;
        }
        
        if (textField == paidField) {
            [_thisPayment putMoneyValueAsAString:[paidField text]];
            [paidField setText:[_thisPayment getMoneyValueInCurrencyAsAString]];
//            _didSomethingChange = MCSomethingHasChanged;
        }
    }
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view
{
    
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([_thisPayment payingPerson]) {
        [_selectButton setTitle:[[_thisPayment payingPerson] getFullName] forState:UIControlStateNormal];
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
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            paidField.text = [_thisPayment getMoneyValueInCurrencyAsAString];
            break;
            
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_paymentPresenceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPaymentPresenceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentPresenceTableViewCell" forIndexPath:indexPath];
    
    MCPaymentPresence *paymentPresenceForThisCell = [_dataController objectAtIndexPath:indexPath];
    [[cell nameLabel] setText:[[paymentPresenceForThisCell person] getFullName]];
    cell.personView.image = paymentPresenceForThisCell.person.thumbnail;
    [[cell theSwitch] setOn:[[paymentPresenceForThisCell isPersonPresent] boolValue] animated:NO];
    NSString *owesLabelString = [NSString stringWithFormat:@"owes %@",[paymentPresenceForThisCell getCurrencyStringOfAverageOwe]];
    [[cell owesMoneyLabel] setText:owesLabelString];
    [cell setThisCellsPaymentPresence:paymentPresenceForThisCell];
    
    // When touch in background of a tableViewCell the keyboard will be dismissed.
    [cell setKeyboardDismissDelegate:self];
    
    // Constraint for alignment with headerView of the tableView.
    NSLayoutConstraint *constraintBetweenNameLabelAndPayerLabel = [NSLayoutConstraint constraintWithItem:_selectButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[cell nameLabel] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    NSLayoutConstraint *constraintBetweenPictureInCellAndPictureOfPayer = [NSLayoutConstraint constraintWithItem:[cell personView] attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_categoryImage attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [[self tableView] addConstraints:@[constraintBetweenNameLabelAndPayerLabel, constraintBetweenPictureInCellAndPictureOfPayer]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"selectPayer"]) {
        id destination = [segue destinationViewController];
        if ([destination conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
            [destination setTonightsBill:_tonightsBill];
        }
        if ([destination conformsToProtocol:@protocol(MCThisPaymentProtocol)]) {
            [destination setThisPayment:_thisPayment];
        }
        
        UIPopoverController *myPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        [myPopover setDelegate:self];

        if ([destination isKindOfClass:[MCSelectPayerTableViewController_iPad class]]) {
            __weak MCPaymentTableViewController_iPad *weakSelf = self;
            [destination setDismissMe:^{
                // Will be executed when a tableViewCell is selected.
                [myPopover dismissPopoverAnimated:YES];
                
                __strong MCPaymentTableViewController_iPad *strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf reloadPayerView];
                }
            }];
        }
    }
    
    if ([[segue identifier] isEqualToString:@"openSelectCurrency"]) {
        id destination = [segue destinationViewController];
        if ([destination conformsToProtocol:@protocol(MCThisPaymentProtocol)]) {
            [destination setThisPayment:_thisPayment];
        }
        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
            UIPopoverController *selectCurrencyPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
            selectCurrencyPopover.delegate = self;
            [destination setDismissMe:^{
                NSLog(@"Dismiss from paymentTableViewController.");
                [selectCurrencyPopover dismissPopoverAnimated:YES];
            }];
        }
    }
    
    if ([[segue identifier] isEqualToString:@"selectCategory"]) {
        id destination = [segue destinationViewController];
        if ([destination conformsToProtocol:@protocol(MCThisPaymentProtocol)]) {
            [destination setThisPayment:_thisPayment];
        }
        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
            UIPopoverController *selectCurrencyPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
            selectCurrencyPopover.delegate = self;
            __weak typeof(self) weakSelf = self;
            [destination setDismissMe:^{
                NSLog(@"Dismiss from paymentTableViewController.");
                [selectCurrencyPopover dismissPopoverAnimated:YES];
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf reloadCategoryImageView];
                    [strongSelf setTextForCategoryButton];
                }
            }];
        }
    }
}

@end
