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
#import "MCEmailAddress.h"
#import "MCWeAllPayStoreController.h"

#import "MCTools.h"

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
        image = [UIImage imageNamed:@"girl 100x100"];
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
        image = [UIImage imageNamed:@"girl 100x100"];
    }
    CGSize imageSize = [image size];
    CGRect thumbnailRect = CGRectMake(0, 0, 80, 80);
    float ratio = MAX(thumbnailRect.size.width / imageSize.width, thumbnailRect.size.height / imageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(thumbnailRect.size, NO, 0.0);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:thumbnailRect cornerRadius:5.0 * 1.9];
    [bezierPath addClip];
    
    CGRect imageDrawRect;
    imageDrawRect.size.width = ratio * imageSize.width;
    imageDrawRect.size.height = ratio * imageSize.height;
    imageDrawRect.origin.x = (thumbnailRect.size.width - imageDrawRect.size.width) / 2.0;
    imageDrawRect.origin.y = (thumbnailRect.size.height - imageDrawRect.size.height) / 2.0;
    
    [image drawInRect:imageDrawRect];
    UIImage *thumbnailWithRoundedCorners = UIGraphicsGetImageFromCurrentImageContext();
    [self setPicture:thumbnailWithRoundedCorners];
    
    NSData *thumbnailWithRoundedCornersData = UIImagePNGRepresentation(thumbnailWithRoundedCorners);
    [self setPictureData:thumbnailWithRoundedCornersData];
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

- (NSString *)defaultEmailAddress
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner = %@ AND selected = YES", self];
    
    [request setPredicate:predicate];
    NSError *error;
    NSArray *emailAddresses;
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    emailAddresses = [context executeFetchRequest:request error:&error];
    if (!emailAddresses) {
        NSLog(@"There was error fetching email addresses for %@", [self getFullName]);
        return nil;
    } else {
        if ([emailAddresses count] == 0) {
            return nil;
        } else {
            return [[emailAddresses objectAtIndex:0] emailAddress];
        }
    }
    
}

- (void)addSharedBillObject:(MCSharedBill *)value
{
    NSMutableSet *sharedbills = [[self sharedBill] mutableCopy];
    [sharedbills addObject:value];
    [self setSharedBill:sharedbills];
}

@end
