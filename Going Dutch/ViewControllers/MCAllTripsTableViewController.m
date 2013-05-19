//
//  MCSharedBillsViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCAllTripsTableViewController.h"
#import "MCAllTripsStore.h"
#import "MCSharedBillTableViewController.h"
#import "MCSharedBill.h"
#import "MCPeople.h"
#import "MCAllTripsTableViewCell.h"
#import "MCTwoLabelsTitleView.h"

@interface MCAllTripsTableViewController ()

@end

@implementation MCAllTripsTableViewController

#pragma mark - Actions

- (void) addButtonFromTableViewCell:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    
	NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint: [touch locationInView:[self tableView]]];
	if (indexPath != nil)
	{
        [self tableView:[self tableView] accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

- (void)addTrip:(id)sender
{
    // Create and add new Trip with a test group.
    MCSharedBill *newTrip = [[MCSharedBill alloc] init];
    [[MCAllTripsStore sharedList] addTrip:newTrip];
    
    // Find the NSArray index of where the object is present and put it in a NSIndexPath object.
    NSInteger lastRow = [[[MCAllTripsStore sharedList] allTrips] indexOfObject:newTrip];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    // Tell the table view to insert the cell.
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
    MCSharedBillTableViewController *tvc = [[MCSharedBillTableViewController alloc] initWithSharedBill:newTrip];
    [[self navigationController] pushViewController:tvc animated:YES];
}

#pragma mark - New in this class.

#pragma mark - Inherited from super

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        [MCAllTripsStore sharedList];
        [[self navigationItem] setTitle:@"back"];
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
    [super viewWillAppear:animated];
    
    if (!titleView) {
        titleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        [[self navigationItem] setTitleView:titleView];
    }
    [[titleView mainLabel] setText:@"We All Pay"];
    [[titleView subLabel] setText:@"Version 0.7.2"];
    
    [[self tableView] reloadData];
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addTrip:)];
    [self setToolbarItems:[NSArray arrayWithObjects:flexButton, bbi, nil] animated:YES];
    [[self navigationController] setToolbarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the nib file
    UINib *nib = [UINib nibWithNibName:@"MCAllTripsTableViewCell" bundle:nil];
    
    // Register this nib that contains the cell.
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"MCAllTripsTableViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MCReturnPaymentViewControllerDelegate

- (void)removePayment:(MCPayment *)payment fromPaymentViewController:(MCPaymentViewController *)pvc
{
    NSLog(@"removePayment in AllTripsTableViewController.");
    [[pvc tonightsBill] removePayment:payment];
    [[self tableView] reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[MCAllTripsStore sharedList] allTrips] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBill *thisTrip = [[[MCAllTripsStore sharedList] allTrips] objectAtIndex:[indexPath row]];
    MCAllTripsTableViewCell *allTripsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MCAllTripsTableViewCell"];
    
    [[allTripsTableViewCell tripLabel] setText:[thisTrip tripName]];
    [[allTripsTableViewCell peoplePresentLabel] setText:[[thisTrip people] stringOfApproxPeoplePresent]];
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *m = [[NSNumber alloc] initWithDouble:[thisTrip totalSumOfMoneyOfThisSharedBill]];
    NSString *moneyString = [nf stringFromNumber:m];
    [[allTripsTableViewCell totalCostLabel] setText:moneyString];
    [[allTripsTableViewCell extraLabel] setText:@""];
    
    // [allTripsTableViewCell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus sign"]]];
    CGRect buttonRect = CGRectMake(0, 0, 44, 44);
    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:buttonRect];
    UIImage *plusSign = [UIImage imageNamed:@"plus sign"];
    [accessoryButton setImage:plusSign forState:UIControlStateNormal];
    [accessoryButton addTarget:self action:@selector(addButtonFromTableViewCell:event:) forControlEvents:UIControlEventTouchUpInside];
    [allTripsTableViewCell setAccessoryView:accessoryButton];
    
    return allTripsTableViewCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCAllTripsStore *allTripStore = [MCAllTripsStore sharedList];
        [allTripStore removeTrip:[[allTripStore allTrips] objectAtIndex:[indexPath row]]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBill *thisBill = [[[MCAllTripsStore sharedList] allTrips] objectAtIndex:[indexPath row]];
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:nil fromBill:thisBill];
    [pvc setDelegate:self];
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBillTableViewController *tonightsTripView = [[MCSharedBillTableViewController alloc] initWithSharedBill:[[[MCAllTripsStore sharedList] allTrips] objectAtIndex:[indexPath row]]];
    [self.navigationController pushViewController:tonightsTripView animated:YES];
}

@end
