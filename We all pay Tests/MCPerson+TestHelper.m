//
//  MCPerson+TestHelper.m
//  We all pay Tests
//
//  Created by Mark Cornelisse on 16/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

#import "MCPerson+TestHelper.h"

@implementation MCPerson (TestHelper)

+ (BOOL)isTableInDatabaseEmptyForManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *request = [MCPerson fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]];
    request.predicate =  [NSPredicate predicateWithValue:YES];
    NSError *error;
    NSInteger amountOfPeople = [managedObjectContext countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error's shouldn't occur.");
        abort();
    }
    return (amountOfPeople == 0);
}

@end
