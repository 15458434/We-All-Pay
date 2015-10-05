//
//  MCSharedBillPeoplePresentTableViewController-iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 02-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillPeoplePresentTableViewController-iPad.h"
#import "UIViewController+WeAllPayStore.h"

#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"

#import "MCWeAllPayStoreController.h"

#import "MCDismissMeBlockProtocol.h"

#import "MCWhoPayingUserDefaultsStoreInterface+WeAllPay.h"

#import "We_all_pay-Swift.h"

@interface MCSharedBillPeoplePresentTableViewController_iPad ()

@property (nonatomic, strong) NSFetchedResultsController *dataController;

@end

@implementation MCSharedBillPeoplePresentTableViewController_iPad

#pragma mark - New in this class

- (void)performFetchAndReloadTableView:(NSNotification *)notification
{
    UIManagedDocument *weAllPayDocument = [[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument];
    if ([weAllPayDocument documentState] == UIDocumentStateNormal) {
        [self performFetch];
        [[self tableView] reloadData];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self setEmptyMessageNow];
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

- (void)setEmptyMessage
{
    if (![[_dataController fetchedObjects] count] == 0) {
        [UIView animateWithDuration:1.0 animations:^{
            [[emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        if ([[emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:1.0 animations:^{
                [[emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
}

- (void)setEmptyMessageNow
{
    if (![[_dataController fetchedObjects] count] == 0) {
        [UIView animateWithDuration:0.0 animations:^{
            [[emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        if ([[emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:0.0 animations:^{
                [[emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
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
    
    [self startRespondingToStoreChangeNotifications];
    
    emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage_iPad" owner:self options:nil][0];
    [[emptyMessage bigMessage] setText:NSLocalizedString(@"PEOPLE_LIST_EMPTY_MESSAGE", @"Press \"add Person\" to add a person who you'd like to share this bill with.")];
    [[emptyMessage bigMessage] setAlpha:0.0];
    [[self tableView] setBackgroundView:emptyMessage];
    self.tableView.estimatedRowHeight = 120.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Get tonightsBill from parentViewController
    id myParent = [self parentViewController];
    if ([myParent conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
        _tonightsBill = [myParent tonightsBill];
    }
    
    if (!_dataController) {
        _dataController = [[MCWeAllPayStoreController defaultStore] sharedBillPeoplePresentDataControllerForDelegate:self];
        [self performFetch];
        [[self tableView] reloadData];
        [self setEmptyMessageNow];
    }
//    UIManagedDocument *weAllPayDocument = [[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument];
//    if (![[MCWeAllPayStoreController defaultStore] isDocumentStateNormal]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetchAndReloadTableView:) name:UIDocumentStateChangedNotification object:weAllPayDocument];
//    } else {
//        [self performFetch];
//        [[self tableView] reloadData];
//        [self setEmptyMessageNow];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"People on screen");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Core Data Notifications

- (void)storeWillBeSwapped:(NSNotification *)notification
{
    [super storeWillBeSwapped:notification];
    typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf view] setUserInteractionEnabled:NO];
        }
    });
}

-(void)storeDidSwap:(NSNotification *)notification
{
    [super storeDidSwap:notification];
    typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf.dataController) {
                NSError *fetchError;
                if (![strongSelf.dataController performFetch:&fetchError]) {
                    NSLog(@"Error fetching: %@", fetchError);
                }
            }
            [[strongSelf tableView] reloadData];
            [[strongSelf view] setUserInteractionEnabled:YES];
        }
    });
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
            [self setEmptyMessage];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Bazinga");
    [self performSegueWithIdentifier:@"openPerson" sender:self];
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
    return [[_dataController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPerson *thisCellsPerson = [_dataController objectAtIndexPath:indexPath];
    PersonTableViewCell_iPad *thisCell = [tableView dequeueReusableCellWithIdentifier:@"MCPersonTableViewCell_iPad"];
    
    thisCell.personImage.image = thisCellsPerson.picture;
    [[thisCell nameLabel] setText:[thisCellsPerson getFullName]];
    [[thisCell emailLabel] setText:[thisCellsPerson defaultEmailAddress]];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[thisCell totalSpent] setText:[nf stringFromNumber:thisCellsPerson.totalSumPaid]];
    
    return thisCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if ([_tonightsBill hasPersonPaidSomething:[_dataController objectAtIndexPath:indexPath]]) {
        return NO;
    } else {
        return [tableView isEditing];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [MCWhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:_tonightsBill];
        [MCPerson deletePerson:[_dataController objectAtIndexPath:indexPath]];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"openPerson"]) {
        id destination = [[segue destinationViewController] viewControllers][0];
        if ([destination conformsToProtocol:@protocol(MCThisPersonProtocol)]) {
            NSIndexPath *ip = [[self tableView] indexPathForSelectedRow];
            [destination setThisPerson:[_dataController objectAtIndexPath:ip]];
            [[self tableView] deselectRowAtIndexPath:ip animated:YES];
        }
//        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
//            __weak MCSharedBillPeoplePresentTableViewController_iPad *weakSelf = self;
//            [destination setDismissMe:^{
//                MCSharedBillPeoplePresentTableViewController_iPad *strongSelf = weakSelf;
//                if (strongSelf) {
////                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
////                    [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
////                    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
//                }
//            }];
//        }
    }
}

@end
