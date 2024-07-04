//
//  MCPerson+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPerson+addons.h"
#import "MCPayment.h"
#import "MCSharedBill.h"
#import "MCEmailAddress+addons.h"
#import "MCWeAllPayStoreController.h"

NS_ASSUME_NONNULL_BEGIN

@implementation MCPerson (addons)

#pragma mark - Core Data Mutations

+ (MCPerson *)addPerson
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] viewContext];
    return [MCPerson addPersonInContext:context];
}

+ (MCPerson *)addPersonInContext:(NSManagedObjectContext *)context
{
    MCPerson *newPerson;
    newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"MCPerson" inManagedObjectContext:context];
    [newPerson setUniquePersonId:[[NSUUID UUID] UUIDString]];
    NSDate *nu = [NSDate date];
    [newPerson setDateCreated:nu];
    [newPerson setDateModified:nu];
    return newPerson;
}

+ (void)deletePerson:(MCPerson *)delPerson
{
    [[delPerson managedObjectContext] deleteObject:delPerson];
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] viewContext];
    return [MCPerson isTableInDatabaseEmptyForContext:context];
}

+ (BOOL)isTableInDatabaseEmptyForContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    NSSortDescriptor *sortDiscriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSArray *sortDescriptorArray = @[sortDiscriptor];
    [request setSortDescriptors:sortDescriptorArray];

    NSError *error;
    NSArray *people = [context executeFetchRequest:request error:&error];
    if (people) {
        if ([people count] == 0) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)setThumbnailDataFromImage:(nullable UIImage *)image
{
    UIImage *thisImage = image;
    if (!thisImage) {
        thisImage = [UIImage imageNamed:@"No picture Image 3 - thumbnail"];
    }
    self.thumbnail = thisImage;
    self.thumbnailData = UIImagePNGRepresentation(thisImage);
}

- (void)setPictureDataFromImage:(nullable UIImage *)image
{
    UIImage *thisImage = image;
    if (!thisImage) {
        thisImage = [UIImage imageNamed:@"No picture Image 3 - picture"];
    }
    self.picture = thisImage;
    self.pictureData = UIImagePNGRepresentation(thisImage);
}

- (NSString *)getFullName
{
    if ([self firstName ] && [self lastName]) {
        return [[NSString alloc] initWithFormat:@"%@ %@", [self firstName], [self lastName]];
    } else if ([self firstName] && ![self lastName]) {
        return [self firstName];
    } else if (![self firstName] && [self lastName]) {
        return [self lastName];
    } else  if ([self defaultEmailAddress]) {
        return [self defaultEmailAddress];
    } else {
        return @"...";
    }
}

- (NSString *)getName
{
    if ([self firstName]) {
        return [self firstName];
    } else if ([self lastName]) {
        return [self lastName];
    } else if ([self defaultEmailAddress]) {
        return [self defaultEmailAddress];
    } else {
        return @"...";
    }
}

- (void)addOneEmailAddressFromAString:(NSString *)emailAddressAsString
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"emailAddress" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"emailAddress = %@ AND owner = %@", emailAddressAsString, self];

    NSError *error;
    NSUInteger amountOfEqualEmailAddresses = [[self managedObjectContext] countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"something went wrong in the search for equal email addresses");
    }
    MCEmailAddress *newEmailAddress;
    if (amountOfEqualEmailAddresses == 0) {
        newEmailAddress = [MCEmailAddress addEmailAddressFor:self];
        if ([[self emailAddress] count] == 1) {
            [newEmailAddress setSelected:@YES];
        } else {
            [newEmailAddress setSelected:@NO];
        }
        [newEmailAddress setEmailAddress:emailAddressAsString];
        NSDate *nu = [NSDate date];
        [newEmailAddress setDateModified:nu];
        [self setDateModified:nu];
    }
}

- (nullable NSString *)defaultEmailAddress
{
    MCEmailAddress *emailAddress = [self getDefaultEmailAddressObject];
    return [emailAddress emailAddress];
}

- (void)addNewDefaultEmailAddressFromAString:(NSString *)newEmailAddressString
{
    MCEmailAddress *oldDefaultEmailAddress = [self getDefaultEmailAddressObject];
    if (oldDefaultEmailAddress) {
        [oldDefaultEmailAddress setSelected:@NO];
        [oldDefaultEmailAddress setDateModified:[NSDate date]];
    }
    MCEmailAddress *newEmailAddress = [MCEmailAddress addEmailAddressFor:self];
    [newEmailAddress setEmailAddress:newEmailAddressString];
    [newEmailAddress setSelected:@YES];
    [self setDateModified:[NSDate date]];
}

- (nullable MCEmailAddress *)getDefaultEmailAddressObject
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner = %@ AND selected = YES", self];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uniqueEmailId" ascending:YES];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    NSError *error;
    
    NSArray *emailAddresses = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!emailAddresses) {
        NSLog(@"Something went wrong on fetching emailAddresses: %@", error);
    } else if ([emailAddresses count] != 1) {
        NSLog(@"%lu defaultEmailAddresses found.", (unsigned long)[emailAddresses count]);
    }
    return [emailAddresses firstObject];
}

- (void)setNewDefaultEmailaddressObject:(MCEmailAddress *)newDefaultEmailAddress {
    // Get current defaultEmailAddressObject.
    MCEmailAddress *currentDefaultEmailAddress = [self getDefaultEmailAddressObject];
    currentDefaultEmailAddress.selected = @NO;
    newDefaultEmailAddress.selected = @YES;
    NSDate *now = [NSDate date];
    newDefaultEmailAddress.dateModified = now;
    currentDefaultEmailAddress.dateModified = now;
}

- (void)deleteEmailAddress:(MCEmailAddress *)eAddress
{
    if ([[eAddress selected] boolValue]) {
        NSString *emailAddressString = [eAddress emailAddress];
        [MCEmailAddress deleteEmailAddress:eAddress];
        MCEmailAddress *newDefault;
        for (MCEmailAddress *ea in [self emailAddress]) {
            if (![[ea emailAddress] isEqualToString:emailAddressString]) {
                newDefault = ea;
                break;
            }
        }
        [newDefault setSelected:@YES];
    } else {
        [MCEmailAddress deleteEmailAddress:eAddress];
    }
}

- (void)addSharedBillObject:(MCSharedBill *)value
{
    NSMutableSet *sharedbills = [[self sharedBill] mutableCopy];
    [sharedbills addObject:value];
    [self setSharedBill:sharedbills];
}

- (BOOL)isThereAnEmailAddress
{
    if (![self emailAddress]) {
        return NO;
    } else if ([[self emailAddress] count] == 0) {
        return NO;
    } else {
        NSUInteger i = 0;
        for (MCEmailAddress *ea in [self emailAddress]) {
            if ([ea isDeleted]) {
                i++;
            }
        }
        if (i == [[self emailAddress] count]) {
            return NO;
        }
        return YES;
    }
}

- (BOOL)hasPersonMadePaymentWithInvalidExchangeRates
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MCExchangeRate"];
    request.predicate = [NSPredicate predicateWithFormat:@"payment.payingPerson = %@ AND status != 0", self];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *countError;
    NSUInteger amountOfInvalidExchangeRates = [context countForFetchRequest:request error:&countError];
    if (countError) {
        NSLog(@"Error counting invalid ExchangeRates: %@", countError);
    }
    if (amountOfInvalidExchangeRates > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)deletAllEmailAddresses
{
    NSSet *copyOfEmailAddresses = [[self emailAddress] copy];
    for (MCEmailAddress *ea in copyOfEmailAddresses) {
        [MCEmailAddress deleteEmailAddress:ea];
    }
}

#pragma mark - Getter and setter stuff.

- (nullable NSNumber *)totalSumPaid
{
    // This doesn't check for the absense of total presence on this tonightsBill
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *fetchResult = [[self payments] sortedArrayUsingDescriptors:sortDescriptors];
    return [fetchResult valueForKeyPath:@"@sum.moneyInMainCurrency"];
}

- (nullable UIImage *)thumbnail
{
    return [UIImage imageWithData:[self thumbnailData]];
}

- (nullable UIImage *)picture
{
    return [UIImage imageWithData:[self pictureData]];
}

#pragma mark - NSManagedObject stuff

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
//    // Extract the thumbnail image from the data.
//    [self setPrimitiveValue:[UIImage imageWithData:[self thumbnailData]] forKey:@"thumbnail"];
//    // Extract the picture image from the data.
//    [self setPrimitiveValue:[UIImage imageWithData:[self pictureData]] forKey:@"picture"];
}

@end

NS_ASSUME_NONNULL_END
