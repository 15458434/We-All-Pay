//
//  MCPaymentTableViewController_iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 06-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentTableViewController_iPad.h"
#import "MCSelectPayerTableViewController_iPad.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"

@interface MCPaymentTableViewController_iPad ()

@end

@implementation MCPaymentTableViewController_iPad

#pragma mark - Actions

- (IBAction)mainCancelPressed:(id)sender
{
    if (_didSomethingChange == MCSomethingHasChanged) {
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


#pragma mark - New in this class

- (void)reloadPayerLabel
{
    [payerLabel setText:[[_thisPayment payingPerson] getFullName]];
    _didSomethingChange = MCSomethingHasChanged;
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
    [[MCWeAllPayStoreController defaultStore] beginUndoGroup];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!_thisPayment) {
        _thisPayment = [_tonightsBill addPayment];
        _didSomethingChange = MCSomethingHasChanged;
    } else {
        [payerLabel setText:[[_thisPayment payingPerson] getFullName]];
        [itemField setText:[_thisPayment descriptionOfPayment]];
        if ([_thisPayment money]) {
            [paidField setText:[_thisPayment getMoneyValueInCurrencyAsAString]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [payerLabel setText:[[_thisPayment payingPerson] getFullName]];
}

#pragma mark - Table view delegate

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
