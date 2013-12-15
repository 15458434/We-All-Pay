//
//  MCTripInfoViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 15-12-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCTripInfoViewController.h"

#import "MCSharedBill+addons.h"
#import "MCTools.h"
#import "MCWeAllPayStoreController.h"

@interface MCTripInfoViewController ()

@end

@implementation MCTripInfoViewController

#pragma mark - New in this class.

@synthesize tonightsBill;



# pragma mark - Inherited from super.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set adBanner.
    [MCTools setAdBannerIfNotPaid:YES forViewController:self];
    
    // Start undomanager group.
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [[context undoManager] enableUndoRegistration];
    [[context undoManager] beginUndoGrouping];
    
    // If tonightsBill doesn't exist consider it new and create one.
    if (!tonightsBill) {
        tonightsBill = [MCSharedBill addSharedBill];
    }
    // Load data to the screen.
    [tripNameField setText:[tonightsBill tripName]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == tripNameField) {
        [tonightsBill setTripName:[textField text]];
    }
}

#pragma mark - actions

- (IBAction)cancelPressed:(id)sender {
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        [[context undoManager] endUndoGrouping];
        [[context undoManager] undoNestedGroup];
        [[context undoManager] disableUndoRegistration];
    }];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)donePressed:(id)sender {
    // Dismiss view and keep changes
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        [tonightsBill setDateModified:[NSDate date]];
        [[context undoManager] endUndoGrouping];
        [[context undoManager] disableUndoRegistration];
    }];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}
@end
