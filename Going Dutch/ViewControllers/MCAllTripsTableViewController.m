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
#import "MCPaymentViewController.h"
#import "MCPeople.h"

@interface MCAllTripsTableViewController ()

@end

@implementation MCAllTripsTableViewController

- (void)reloadButton:(id)sender
{
    [[self tableView] reloadData];
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

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        [MCAllTripsStore sharedList];
        [[self navigationItem] setTitle:@"Project X"];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addTrip:)];
        [[self navigationItem] setRightBarButtonItem:bbi animated:YES];
        
        UIBarButtonItem *rb = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                            target:self
                                                                            action:@selector(reloadButton:)];
        [[self navigationItem] setLeftBarButtonItem:rb animated:YES];
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
    [[self tableView] reloadData];
    [[self navigationController] setToolbarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [[[MCAllTripsStore sharedList] allTrips] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MCAllTripsStoreCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Fill the cell text Label with the description of the trip.
    MCSharedBill *thisTrip = [[[MCAllTripsStore sharedList] allTrips] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[thisTrip description]];
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBill *thisBill = [[[MCAllTripsStore sharedList] allTrips] objectAtIndex:[indexPath row]];
    MCPayment *newPayment = [[MCPayment alloc] init];
    [newPayment setPayingPerson:[[[thisBill people] allPeople] objectAtIndex:0]];
    [thisBill addPayment:newPayment];
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:newPayment fromBill:thisBill];
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBillTableViewController *tonightsTripView = [[MCSharedBillTableViewController alloc] initWithSharedBill:[[[MCAllTripsStore sharedList] allTrips] objectAtIndex:[indexPath row]]];
    [self.navigationController pushViewController:tonightsTripView animated:YES];
}

@end
