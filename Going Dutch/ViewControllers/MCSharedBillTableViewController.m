//
//  MCSharedBillTableViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillTableViewController.h"
#import "MCSharedBill.h"
#import "MCPayment.h"
#import "MCAllTripsTableViewController.h"
#import "MCCreateNewTripViewController.h"
#import "MCPaymentViewController.h"
#import "MCAllTripsStore.h"

@interface MCSharedBillTableViewController ()

@end

@implementation MCSharedBillTableViewController

@synthesize tonightsBill;

// Actions

- (void)addPayment:(id)sender
{
    /*MCPayment *newPayment = [MCPayment createRandomPaymentWithGroup:[tonightsBill people]];
    if (newPayment) {
        [tonightsBill addPayment:newPayment];
    } else {
        newPayment = [[MCPayment alloc] init];
    }
    NSInteger lastRow = [[tonightsBill allPayments] indexOfObject:newPayment];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];*/
    
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:nil fromBill:tonightsBill];
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (void)editBillData:(id)sender
{
    MCCreateNewTripViewController *tvc = [[MCCreateNewTripViewController alloc] initWithBill:tonightsBill isNew:NO];
    [[self navigationController] pushViewController:tvc animated:YES];
}

- (void)showWhoPaysWho:(id)sender
{
    // Still needs to be implement.
    NSLog(@"Solving has not been implemented yet.");
}

- (void)shareBill:(id)sender
{
    NSLog(@"Share this bill has not been implemented yet.");
}

- (id)initWithSharedBill:(MCSharedBill *)tBill
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        tonightsBill = tBill;
        [[self navigationItem] setTitle:[tBill tripName]];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                    target:self
                                                                                    action:@selector(editBillData:)];
        [[self navigationItem] setRightBarButtonItem:editButton animated:YES];

    }
    return self;
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        tonightsBill = [[MCSharedBill alloc] initWithTestGroup];
        [[self navigationController] setTitle:@"Test"];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addPayment:)];
        [[self navigationItem] setRightBarButtonItem:bbi animated:YES];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self tableView] reloadData];
    [[self navigationItem] setTitle:[tonightsBill tripName]];
    
    [[self navigationController] setToolbarHidden:NO animated:YES];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                 target:self
                                                                                 action:@selector(shareBill:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addPayment:)];
    UIBarButtonItem *solveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                 target:self
                                                                                 action:@selector(showWhoPaysWho:)];
    NSArray *bottomButtonArray = [[NSArray alloc] initWithObjects:shareButton, flexibleSpace, solveButton, flexibleSpace, addButton, nil];
    [self setToolbarItems:bottomButtonArray animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // if there are NO people on this SharedBill go to the people addscreen
    if (![tonightsBill areTherePeople]) {
        MCCreateNewTripViewController *pvc = [[MCCreateNewTripViewController alloc] initWithBill:tonightsBill isNew:YES];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pvc];
        [pvc setDismissblock:^{
            [[self tableView] reloadData];
        }];
        [pvc setDismissYourSelf:^{
            [[self navigationController] popViewControllerAnimated:YES];
        }];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[self view] endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[tonightsBill allPayments] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Check to see if an unused cell is available if not make a new one.
    static NSString *CellIdentifier = @"TableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Get payment and put it's description in the cell.
    MCPayment *thisCellsPayment = [[tonightsBill allPayments] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[thisCellsPayment description]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCPayment *toBeDeletedPayment = [[tonightsBill allPayments] objectAtIndex:[indexPath row]];
        [tonightsBill removePayment:toBeDeletedPayment];
    }
    [[self tableView] reloadData];
}


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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:[[tonightsBill allPayments] objectAtIndex:[indexPath row]] fromBill:tonightsBill];
    [[self navigationController] pushViewController:pvc animated:YES];
}

@end
