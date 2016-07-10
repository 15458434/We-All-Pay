//
//  MCTools.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 08-04-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCTools.h"
#import "We_all_pay-Swift.h"

@implementation MCTools

+ (BOOL)isStringAnEmailAddress:(NSString * _Nonnull)stringThatIsSupposedToBeEmailAddress
{
    NSParameterAssert(stringThatIsSupposedToBeEmailAddress);
    if([stringThatIsSupposedToBeEmailAddress length] == 0){
        return NO;
    }
    
    NSString *emailPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *re = [[NSRegularExpression alloc] initWithPattern:emailPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger amountOfMatches = [re numberOfMatchesInString:stringThatIsSupposedToBeEmailAddress options:0 range:NSMakeRange(0, [stringThatIsSupposedToBeEmailAddress length])];
    if (amountOfMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

@end
