//
//  MCBitwiseStuff.h
//  We all pay
//
//  Created by Mark Cornelisse on 30/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

@import Foundation;

/// Sets the bits that are 1 in the 2nd NSUInteger to 1 in the 1st NSUInteger
/// @param valueToChange The NSUInteger where to enable bits.
/// @param bitsToSet The NSUInteger containing the bits to set to 1.
OBJC_EXTERN NSUInteger enableBits(NSUInteger valueToChange, NSUInteger bitsToSet);

/// Sets the bits that are 1 in the 2nd NSUInteger to 0 in the 1st NSUInteger
/// @param valueToChange The NSUInteger where to disbable bits.
/// @param bitsToUnset The NSUInteger containing the bits to set to 0.
OBJC_EXTERN NSUInteger disableBits(NSUInteger valueToChange, NSUInteger bitsToUnset);

/// Does valueToCheck contain the same bits.
/// @param valueToCheck The NSUInteger that has some bits verified.
/// @param valueToCheckAgainst The NSUInteger that has the bits used to verify.
OBJC_EXTERN BOOL containsBits(NSUInteger valueToCheck, NSUInteger valueToCheckAgainst);
