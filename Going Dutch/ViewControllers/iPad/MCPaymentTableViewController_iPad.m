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

#import "MCPaymentPresenceTableViewCell.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCpaymentPresence+addons.h"

@interface MCPaymentTableViewController_iPad ()

@end

@implementation MCPaymentTableViewController_iPad

#pragma mark - Actions

- (IBAction)mainCancelPressed:(id)sender
{
    _mainCancelPressed = cancelIsPressed;
    if ([[[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext] undoManager] canUndo]) {
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
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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


- (void)reloadPayerLabel
{
    [selectButton setTitle:[[_thisPayment payingPerson] getFullName] forState:UIControlStateNormal];
    [self setCircularImageOnPictureView:[[_thisPayment payingPerson] picture]];
    _didSomethingChange = MCSomethingHasChanged;
}

- (void)setCircularImageOnPictureView:(UIImage *)image
{
    __weak MCPaymentTableViewController_iPad *weakSelf = self;
    
    dispatch_queue_t imageProcessQueue;
    imageProcessQueue = dispatch_queue_create("imageProcessQueue", NULL);
    
    dispatch_async(imageProcessQueue, ^{
        CGRect circularImageRect = CGRectMake(0, 0, 160, 160);
        UIImage *circularImage = [MCTools cutCircularImageFrom:image toDestinationRect:circularImageRect];
        dispatch_async(dispatch_get_main_queue(), ^{
            MCPaymentTableViewController_iPad *strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf payerPicture] setImage:circularImage];
                [[strongSelf payerPicture] setNeedsDisplay];
            }
        });
    });
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
    
    _didSomethingChange = MCNothingHasChanged;
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
        _didSomethingChange = MCSomethingHasChanged;
        _isNew = isNew;
        NSString *newTitle = NSLocalizedString(@"NEW_PAYMENT_HEADER", "new payment");
        [self setTitle:newTitle];
    } else {
        if ([_thisPayment payingPerson]) {
            [selectButton setTitle:[[_thisPayment payingPerson] getFullName] forState:UIControlStateNormal];
        }
        [itemField setText:[_thisPayment descriptionOfPayment]];
        if ([_thisPayment money]) {
            [paidField setText:[_thisPayment getMoneyValueInCurrencyAsAString]];
        }
        if ([[_thisPayment payingPerson] picture]) {
            [self setCircularImageOnPictureView:[[_thisPayment payingPerson] picture]];
        }
        _isNew = isNotNew;
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"person.firstName" ascending:YES];
    _paymentPresenceArray = [[_thisPayment peopleSharingPayment] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    _dataController = [[MCWeAllPayStoreController defaultStore] paymentPresenceDataControllerForDelegate:self];
    UIManagedDocument *weAllPayDocument = [[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument];
    if (![[MCWeAllPayStoreController defaultStore] isDocumentStateNormal]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetchAndReloadTableView:) name:UIDocumentStateChangedNotification object:weAllPayDocument];
    } else {
        [self performFetch];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    if (isNew) {
        [tracker set:kGAIScreenName value:@"MCPaymentNewView_iPad"];
    } else {
        [tracker set:kGAIScreenName value:@"MCPaymentDetailsView_iPad"];
    }
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidDisappear:animated];
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
            _didSomethingChange = MCSomethingHasChanged;
        }
        
        if (textField == paidField) {
            [_thisPayment putMoneyValueAsAString:[paidField text]];
            [paidField setText:[_thisPayment getMoneyValueInCurrencyAsAString]];
            _didSomethingChange = MCSomethingHasChanged;
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
        [selectButton setTitle:[[_thisPayment payingPerson] getFullName] forState:UIControlStateNormal];
        if ([[_thisPayment payingPerson] picture]) {
            [self setCircularImageOnPictureView:[[_thisPayment payingPerson] picture]];
        }
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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 71;
//}

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
    [cell setCircularImage:[[paymentPresenceForThisCell person] thumbnail]];
    [[cell theSwitch] setOn:[[paymentPresenceForThisCell isPersonPresent] boolValue] animated:NO];
    NSString *owesLabelString = [NSString stringWithFormat:@"owes %@",[paymentPresenceForThisCell getCurrencyStringOfAverageOwe]];
    [[cell owesMoneyLabel] setText:owesLabelString];
    [cell setThisCellsPaymentPresence:paymentPresenceForThisCell];
    
    // When touch in background of a tableViewCell the keyboard will be dismissed.
    [cell setKeyboardDismissDelegate:self];
    
    // Constraint for alignment with headerView of the tableView.
    NSLayoutConstraint *constraintBetweenNameLabelAndSelectButton = [NSLayoutConstraint constraintWithItem:selectButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[cell nameLabel] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    NSLayoutConstraint *constraintBetweenPictureInCellAndPictureOfPayer = [NSLayoutConstraint constraintWithItem:[cell personView] attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_payerPicture attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [[self tableView] addConstraints:@[constraintBetweenNameLabelAndSelectButton, constraintBetweenPictureInCellAndPictureOfPayer]];
    
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
        if ([destination conformsToProtocol:@protocol(MCTonightsBillPut)]) {
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
                    [strongSelf reloadPayerLabel];
                }
            }];
        }
    }
}

@end
