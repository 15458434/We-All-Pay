//
//  MCMailComposer.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCMailComposer.h"

#import "MCReturnPayment.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"

@implementation MCMailComposer

#pragma mark - Private methods.



#pragma mark - New in this class.

- (NSArray *)getMailAddresses
{
    NSArray *sortDescriptorArray = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *allPeople = [[_tonightsBill peoplePresent] sortedArrayUsingDescriptors:sortDescriptorArray];
    // Create a list of all email addresses
    NSMutableArray *listOfMailAddresses = [[NSMutableArray alloc] init];
    for (MCPerson *person in allPeople) {
        if ([person defaultEmailAddress]) {
            [listOfMailAddresses addObject:[person defaultEmailAddress]];
        }
    }
    return listOfMailAddresses;
}

- (NSString *)getSubject
{
    NSString *subject1 = NSLocalizedString(@"EMAIL_SUBJECT_PART_ONE", @"Bill overview of our trip to %@");
    return [[NSString alloc] initWithFormat:@"%@ %@.", subject1, [[self tonightsBill] tripName]];
}

- (NSString *)getMailBody
{
    // Generate the text for the email.
    NSMutableString *mailBody = [[NSMutableString alloc] init];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [mailBody appendString:@"https://itunes.apple.com/us/app/we-all-pay/id642135963?mt=8&uo=4\n\n"];
    
    [mailBody appendFormat:@"%@ %@,\n", NSLocalizedString(@"EMAIL_DEAR", @"Just Dear as in \"Dear Mark\""), [[self tonightsBill] stringOfApproxPeoplePresent]];
    [mailBody appendFormat:@"\n"];
    
    NSString *intro1 = NSLocalizedString(@"EMAIL_INTRO_PART_ONE", @"From a total of \"$ 20,45\", which was spend on our last trip to \"Movies\". We all have to pay an equal share of \"$6,82\".");
    NSString *intro2 = NSLocalizedString(@"EMAIL_INTRO_PART_TWO", @"From a total of \"$ 20,45\", which was spend on our last trip to \"Movies\". We all have to pay an equal share of \"$6,82\".");
    NSString *intro3 = NSLocalizedString(@"EMAIL_INTRO_PART_THREE", @"From a total of \"$ 20,45\", which was spend on our last trip to \"Movies\". We all have to pay an equal share of \"$6,82\".");
    [mailBody appendFormat:@"%@ %@, %@ %@. %@ %@.\n", intro1, [nf stringFromNumber:[[self tonightsBill] totalSumOfMoneyOfThisSharedBill]], intro2,[[self tonightsBill] tripName], intro3, [nf stringFromNumber:[[self tonightsBill] amountPeopleShouldHavePaid]]];
    [mailBody appendFormat:@"\n"];
    
    if ([[self tonightsBill] totalAmountOfPeopleWhoHavePaid] == 0) {
        [mailBody appendFormat:@"%@\n", NSLocalizedString(@"EMAIL_NOBODY_HAS_PAID", @"The message that nobody has paid so far")];
    } else if ([[self tonightsBill] totalAmountOfPeopleWhoHavePaid] == 1) {
        [mailBody appendFormat:@"%@:\n", NSLocalizedString(@"EMAIL_ONE_PERSON_HAS_PAID", @"The person who has payed")];
    } else {
        [mailBody appendFormat:@"%@:\n", NSLocalizedString(@"EMAIL_MULTIPLE_PEOPLE_HAVE_PAID", @"The people who have paid are")];
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    NSArray *allPayments = [[[self tonightsBill] payments] sortedArrayUsingDescriptors:@[sortDescriptor]];
    for (MCPayment *p in allPayments) {
        NSString *whoHasPaid1 = NSLocalizedString(@"EMAIL_WHO_HAS_PAID_ONE", @"Part one of the sentence: Mark has paid $24 for beer.");
        NSString *whoHasPaid2 = NSLocalizedString(@"EMAIL_WHO_HAS_PAID_TWO", @"Part two of the sentence: Mark has paid $24 for beer.");
        [mailBody appendFormat:@"%@ %@ %@ %@ %@.\n", [[p payingPerson] getName], whoHasPaid1, [nf stringFromNumber:[p money]], whoHasPaid2, [p descriptionOfPayment]];
    }
    [mailBody appendFormat:@"\n"];

//    NSString *averageOfUse = @"We agreed to pay an equal share on what we used. ";
    NSString *averageOfUse = NSLocalizedString(@"EMAIL_AVERAGE_OF_USE_SENTENCE_ONE", @"We agreed to pay an equal share on what we used.");
//    NSString *average1 = NSLocalizedString(@"EMAIL_AVERAGE_SENTENCES_ONE", @"Part one of: To have everybody pay the average of $7.00, I suggest the following solution:");
//    NSString *average2 = NSLocalizedString(@"EMAIL_AVERAGE_SENTENCES_TWO", @"Part two of: To have everybody pay the average of $7.00, I suggest the following solution:");
//    [mailBody appendFormat:@"%@ %@%@:\n", average1, [nf stringFromNumber:[[self tonightsBill] amountPeopleShouldHavePaid]], average2];
    [mailBody appendFormat:@"%@:\n", averageOfUse];

    for (MCPerson *person in [_tonightsBill peoplePresent]) {
        NSString *amountUsedString = [_tonightsBill amountShouldHavePaidAsCurrencyStringBy:person];
        NSString *usedString = NSLocalizedString(@"EMAIL_AMOUNT_USED", @"The word used in the sentence: Mark used $4.00");
        [mailBody appendFormat:@"%@ %@ %@.\n", [person getName], usedString, amountUsedString];
    }
    
    NSString *iSuggestString = NSLocalizedString(@"EMAIL_I_SUGGEST", @"I suggest the following solution.");
    [mailBody appendFormat:@"\n%@\n", iSuggestString];
    for (MCReturnPayment *rp in _solution) {
        [mailBody appendFormat:@"%@\n", [rp stringForMail]];
    }
    [mailBody appendFormat:@"\n"];
    [mailBody appendFormat:@"%@.", NSLocalizedString(@"EMAIL_FINAL SENTENCE", @"If you have any remarks please let me know.")];
    return mailBody;
}
@end
