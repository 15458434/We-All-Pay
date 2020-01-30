//
//  MCBitwiseStuff.m
//  We all pay
//
//  Created by Mark Cornelisse on 30/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

#import "MCBitwiseStuff.h"

NSUInteger enableBits(NSUInteger valueToChange, NSUInteger bitsToSet) {
    return valueToChange | bitsToSet;
}

NSUInteger disableBits(NSUInteger valueToChange, NSUInteger bitsToUnset) {
    return valueToChange & ~bitsToUnset;
}

BOOL containsBits(NSUInteger valueToCheck, NSUInteger valueToCheckAgainst) {
    NSUInteger result = valueToCheck & valueToCheckAgainst;
    return result == valueToCheckAgainst;
}
