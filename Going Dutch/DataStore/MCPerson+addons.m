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
    __block MCPerson *newPerson;
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlockAndWait:^{
        newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"MCPerson" inManagedObjectContext:context];
        [newPerson setUniquePersonId:[MCTools createUniqueIdentifierString]];
        NSDate *nu = [NSDate date];
        [newPerson setDateCreated:nu];
        [newPerson setDateModified:nu];
    }];
    return newPerson;
}

+ (void)deletePerson:(MCPerson *)delPerson
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        [context deleteObject:delPerson];
    }];
}

+ (MCPerson *)fetchPersonWithUniqueId:(NSString *)uuid
{
    return nil;
}

- (void)setThumbnailDataFromImage:(UIImage *)image
{
    if (!image) {
        //image = [UIImage imageNamed:@"girl 100x100"];
        image = [UIImage imageNamed:@"No picture image 2 - We All Pay"];
    }
    CGSize imageSize = [image size];
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
    
    [image drawInRect:imageDrawRect];
    UIImage *thumbnailWithRoundedCorners = UIGraphicsGetImageFromCurrentImageContext();
    [self setThumbnail:thumbnailWithRoundedCorners];
    
    NSData *thumbnailWithRoundedCornersData = UIImagePNGRepresentation(thumbnailWithRoundedCorners);
    [self setThumbnailData:thumbnailWithRoundedCornersData];
    UIGraphicsEndImageContext();
}

- (void)setPictureDataFromImage:(UIImage *)image
{
    if (!image) {
        //image = [UIImage imageNamed:@"girl 100x100"];
        image = [UIImage imageNamed:@"No picture image 2 - We All Pay"];
    }
    CGSize imageSize = [image size];
    CGRect pictureRect = CGRectMake(0, 0, 80, 80);
    float ratio = MAX(pictureRect.size.width / imageSize.width, pictureRect.size.height / imageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(pictureRect.size, NO, 0.0);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:pictureRect cornerRadius:5.0 * 1.9];
    [bezierPath addClip];
    
    CGRect imageDrawRect;
    imageDrawRect.size.width = ratio * imageSize.width;
    imageDrawRect.size.height = ratio * imageSize.height;
    imageDrawRect.origin.x = (pictureRect.size.width - imageDrawRect.size.width) / 2.0;
    imageDrawRect.origin.y = (pictureRect.size.height - imageDrawRect.size.height) / 2.0;
    
    [image drawInRect:imageDrawRect];
    UIImage *pictureWithRoundedCorners = UIGraphicsGetImageFromCurrentImageContext();
    [self setPicture:pictureWithRoundedCorners];
    
    NSData *pictureWithRoundedCornersData = UIImagePNGRepresentation(pictureWithRoundedCorners);
    [self setPictureData:pictureWithRoundedCornersData];
    UIGraphicsEndImageContext();
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
    MCEmailAddress *newEmailAddress = [MCEmailAddress addEmailAddressFor:self];
    if ([[self emailAddress] count] == 1) {
        [newEmailAddress setSelected:[NSNumber numberWithBool:YES]];
    } else {
        [newEmailAddress setSelected:[NSNumber numberWithBool:NO]];
    }
    [newEmailAddress setEmailAddress:emailAddressAsString];
}

- (NSString *)defaultEmailAddress
{
    MCEmailAddress *emailAddress = [self getDefaultEmailAddressObject];
    return [emailAddress emailAddress];
}

- (MCEmailAddress *)getDefaultEmailAddressObject
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner = %@ AND selected = YES", self];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uniqueEmailId" ascending:YES];
    [request setPredicate:predicate];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error;
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    NSArray *emailAddresses = [context executeFetchRequest:request error:&error];
    if (!emailAddresses) {
        NSLog(@"Something went wrong on fetching emailAddresses: %@", [error localizedDescription]);
    } else if ([emailAddresses count] != 1) {
        NSLog(@"%d defaultEmailAddresses found.", [emailAddresses count]);
    }
    return [emailAddresses firstObject];
}

- (void)deleteEmailAddress:(MCEmailAddress *)eAddress
{
    if (![[eAddress selected] boolValue]) {
        [MCEmailAddress deleteEmailAddress:eAddress];
    } else {
        NSLog(@"Unable to delete a selected emailAddress.");
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
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    request.predicate = [NSPredicate predicateWithFormat:@"owner = %@", self];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"emailAddress" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    NSArray *emailAdresses = [context executeFetchRequest:request error:&error];
    if (!emailAdresses) {
        NSLog(@"There was an error fetching EmailAddresses.");
        return NO;
    } else {
        if ([emailAdresses count] == 0) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    // Extract the thumbnail image from the data.
    [self setPrimitiveValue:[UIImage imageWithData:[self thumbnailData]] forKey:@"thumbnail"];
    // Extract the picture image from the data
    [self setPrimitiveValue:[UIImage imageWithData:[self pictureData]] forKey:@"picture"];
}

@end
