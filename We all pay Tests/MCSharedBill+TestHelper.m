//
//  MCSharedBill+TestHelper.m
//  We all pay Tests
//
//  Created by Mark Cornelisse on 04/08/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill+TestHelper.h"

@implementation MCSharedBill (TestHelper)

- (BOOL)isPresentWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmailAddress:(NSString *)emailAddress {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    NSArray *sda = @[sortDescriptor1, sortDescriptor2];
    [request setSortDescriptors:sda];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY sharedBill = %@ AND firstName = %@ AND lastName = %@ AND ANY emailAddress.emailAddress = %@", self, firstName, lastName, emailAddress];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!result) {
        NSLog(@"Error checking if person is present: %@", error);
        return NO;
    } else {
        if ([result count] == 0) {
            return NO;
        } else {
            return YES;
        }
    }
}

@end
