//
//  MCSharedBillsViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCAllTripsTableViewController.h"
#import "MCSharedBillTableViewController.h"

#import "MCAllTripsTableViewCell.h"
#import "MCTwoLabelsTitleView.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"

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
    NSLog(@"AddTripPressed");
    // Create and add new Trip with a test group.
    MCSharedBill *newTrip = [MCSharedBill addSharedBill];
    NSLog(@"trip: %@", [newTrip uniqueBillId]);
    MCSharedBillTableViewController *tvc = [[MCSharedBillTableViewController alloc] initWithSharedBill:newTrip];
    [[self navigationController] pushViewController:tvc animated:YES];
}

#pragma mark - New in this class.

#pragma mark - Inherited from super

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        [[self navigationItem] setTitle:@"Back"];
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
    
    if (!dataController) {
        NSManagedObjectContext *context = [[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
        [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]]];
        
        dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                             managedObjectContext:context
                                                               sectionNameKeyPath:nil
                                                                        cacheName:nil];
        [dataController setDelegate:self];
        NSError *error;
        BOOL success = [dataController performFetch:&error];
        if (!success) {
            NSLog(@"Something went wrong");
        }
    }

    // Set the titleView.
    if (!titleView) {
        titleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        [[self navigationItem] setTitleView:titleView];
    }
    [[titleView mainLabel] setText:@"We All Pay"];
    [[titleView subLabel] setText:[NSString stringWithFormat:@"%@ build %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

/*- (void)removePayment:(MCPayment *)payment fromPaymentViewController:(MCPaymentViewController *)pvc
{
    NSLog(@"removePayment in AllTripsTableViewController.");
    [[pvc tonightsBill] removePayment:payment];
    [[self tableView] reloadData];
}*/

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
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //[self configureCell:[[self tableView] cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[dataController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[dataController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBill *thisTrip = [dataController objectAtIndexPath:indexPath];
    MCAllTripsTableViewCell *allTripsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MCAllTripsTableViewCell"];
    
    [[allTripsTableViewCell tripLabel] setText:[thisTrip tripName]];
    [[allTripsTableViewCell peoplePresentLabel] setText:[thisTrip stringOfApproxPeoplePresent]];

    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *moneyString = [nf stringFromNumber:[thisTrip totalSumOfMoneyOfThisSharedBill]];
    [[allTripsTableViewCell totalCostLabel] setText:moneyString];
    
    
    // fill extraLabel with dateModified.
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        [df setTimeStyle:NSDateFormatterShortStyle];
    }
    [[allTripsTableViewCell extraLabel] setText:[df stringFromDate:[thisTrip dateModified]]];
    
    //[allTripsTableViewCell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus sign"]]];
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
        MCSharedBill *toBeDeleteSharedBill = [dataController objectAtIndexPath:indexPath];
        [MCSharedBill deleteSharedbill:toBeDeleteSharedBill];
        [[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext] processPendingChanges];
    }
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
    /*
    MCSharedBill *thisBill = [[[MCAllTripsStore sharedList] allTrips] objectAtIndex:[indexPath row]];
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:nil fromBill:thisBill];
    [pvc setDelegate:self];
    [[self navigationController] pushViewController:pvc animated:YES];
     */
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBillTableViewController *tonightsTripView = [[MCSharedBillTableViewController alloc] initWithSharedBill:[dataController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:tonightsTripView animated:YES];
}

@end
