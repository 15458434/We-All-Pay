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

@implementation MCPerson (addons)

#pragma mark - Core Data Mutations

+ (MCPerson *)addPerson
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    return [MCPerson addPersonInContext:context];
}

+ (MCPerson *)addPersonInContext:(NSManagedObjectContext *)context
{
    MCPerson *newPerson;
    newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"MCPerson" inManagedObjectContext:context];
//    [newPerson setUniquePersonId:[MCTools createUniqueIdentifierString]];
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

+ (MCPerson *)fetchPersonWithUniqueId:(NSString *)uuid
{
    NSLog(@"Has not been implemented yet.");
    return nil;
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
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

- (void)setThumbnailDataFromImage:(UIImage *)image
{
    __block UIImage *thisImage = image;
    if (!thisImage) {
        thisImage = [UIImage imageNamed:@"No picture Image 3 - thumbnail"];
    }
    CGSize imageSize = [thisImage size];
    CGRect thumbnailRect = CGRectMake(0, 0, 44, 44);
    float ratio = MAX(thumbnailRect.size.width / imageSize.width, thumbnailRect.size.height / imageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(thumbnailRect.size, NO, 0.0);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:thumbnailRect cornerRadius:5.0];
    [bezierPath addClip];
    
    CGRect imageDrawRect;
    imageDrawRect.size.width = ratio * imageSize.width;
    imageDrawRect.size.height = ratio * imageSize.height;
    imageDrawRect.origin.x = (thumbnailRect.size.width - imageDrawRect.size.width) / 2.0;
    imageDrawRect.origin.y = (thumbnailRect.size.height - imageDrawRect.size.height) / 2.0;
    [thisImage drawInRect:imageDrawRect];
    UIImage *thumbnailWithRoundedCorners = UIGraphicsGetImageFromCurrentImageContext();

    
    NSData *thumbnailWithRoundedCornersData = UIImagePNGRepresentation(thumbnailWithRoundedCorners);
    UIGraphicsEndImageContext();
    [self setThumbnail:thumbnailWithRoundedCorners];
    [self setThumbnailData:thumbnailWithRoundedCornersData];
}

- (void)setPictureDataFromImage:(UIImage *)image
{
    __block UIImage *thisImage = image;
    if (!thisImage) {
        thisImage = [UIImage imageNamed:@"No picture Image 3 - picture"];
    }
    CGSize imageSize = [thisImage size];
    CGRect pictureRect = CGRectMake(0, 0, 160, 160);
    float ratio = MAX(pictureRect.size.width / imageSize.width, pictureRect.size.height / imageSize.height);
        
    UIGraphicsBeginImageContextWithOptions(pictureRect.size, NO, 0.0);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:pictureRect cornerRadius:5.0 * 1.9];
    [bezierPath addClip];
        
    CGRect imageDrawRect;
    imageDrawRect.size.width = ratio * imageSize.width;
    imageDrawRect.size.height = ratio * imageSize.height;
    imageDrawRect.origin.x = (pictureRect.size.width - imageDrawRect.size.width) / 2.0;
    imageDrawRect.origin.y = (pictureRect.size.height - imageDrawRect.size.height) / 2.0;
        
    [thisImage drawInRect:imageDrawRect];
    UIImage *pictureWithRoundedCorners = UIGraphicsGetImageFromCurrentImageContext();
    NSData *pictureWithRoundedCornersData = UIImagePNGRepresentation(pictureWithRoundedCorners);

    UIGraphicsEndImageContext();
    [self setPicture:pictureWithRoundedCorners];
    [self setPictureData:pictureWithRoundedCornersData];
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
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"emailAddress" ascending:YES];
    NSArray *sortDescriptorArray = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptorArray];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emailAddress = %@ AND owner = %@", emailAddressAsString, self];
    [request setPredicate:predicate];

    NSError *error;
    NSArray *equalEmailAddresses = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"something went wrong in the search for equal email addresses");
    }
    MCEmailAddress *newEmailAddress;
    if ([equalEmailAddresses count] == 0) {
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

- (NSString *)defaultEmailAddress
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

- (MCEmailAddress *)getDefaultEmailAddressObject
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner = %@ AND selected = YES", self];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uniqueEmailId" ascending:YES];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    NSError *error;
    
    NSArray *emailAddresses = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!emailAddresses) {
        NSLog(@"Something went wrong on fetching emailAddresses: %@", [error localizedDescription]);
    } else if ([emailAddresses count] != 1) {
        NSLog(@"%lu defaultEmailAddresses found.", (unsigned long)[emailAddresses count]);
    }
    return [emailAddresses firstObject];
}

- (void)setNewDefaultEmailaddressObject:(MCEmailAddress *)newDefaultEmailAddress
{
    // Get current defaultEmailAddressObject.
    MCEmailAddress *currentDefaultEmailAddress = [self getDefaultEmailAddressObject];
    [currentDefaultEmailAddress setSelected:@NO];
    [newDefaultEmailAddress setSelected:@YES];
    NSDate *nu = [NSDate date];
    [self setDateModified:nu];
    [newDefaultEmailAddress setDateModified:nu];
    [currentDefaultEmailAddress setDateModified:nu];
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
//    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
//    NSArray *array = [context executeFetchRequest:request error:&countError];
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

#pragma mark - NSManagedObject stuff

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    // Extract the thumbnail image from the data.
    [self setPrimitiveValue:[UIImage imageWithData:[self thumbnailData]] forKey:@"thumbnail"];
    // Extract the picture image from the data
    [self setPrimitiveValue:[UIImage imageWithData:[self pictureData]] forKey:@"picture"];
}

@end
