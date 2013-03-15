//
//  MCReturnPaymentViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 07-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCReturnPaymentViewController.h"
#import "MCSharedBill.h"
#import "MCReturnPayment.h"
#import "MCPerson.h"
#import "MCReturnPaymentTableViewCell.h"

@interface MCReturnPaymentViewController ()

@end

@implementation MCReturnPaymentViewController

@synthesize tonightsBill;

#pragma mark - New in this Class

- (id)initWithBill:(MCSharedBill *)thisBill
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        if (!thisBill) {
            @throw [NSException exceptionWithName:@"InitWithNil" reason:@"thisBill is not allowed to point to nil." userInfo:nil];
        }
        tonightsBill = thisBill;
        paymentsAfterwards = [tonightsBill solveWhoHasToPayWhoFromThisBill];
    }
    return self;
}

#pragma mark - Inherited from super.

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
    
    UINib *nib = [UINib nibWithNibName:@"MCReturnPaymentTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"MCReturnPaymentTableViewCell"];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    NSNumber *averagePay = [[NSNumber alloc] initWithDouble:[tonightsBill amountPeopleShouldHavePaid]];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[self navigationItem] setTitle:[[NSString alloc] initWithFormat:@"To pay: %@", [nf stringFromNumber:averagePay]]];
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
    return [paymentsAfterwards count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCReturnPayment *thisCellsReturnPayment = [paymentsAfterwards objectAtIndex:[indexPath row]];
    MCReturnPaymentTableViewCell *returnPaymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCReturnPaymentTableViewCell"];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *moneyToConvert = [[NSNumber alloc] initWithDouble:[thisCellsReturnPayment money]];
    [[returnPaymentCell moneyLabel] setText:[nf stringFromNumber:moneyToConvert]];
    
    NSString *whoOwesWho = [[NSString alloc] initWithFormat:@"%@ owes %@:", [thisCellsReturnPayment payer], [thisCellsReturnPayment receiver]];
    [[returnPaymentCell whoOwesWho] setText:whoOwesWho];
    
    return returnPaymentCell;
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
