//
//  UIColor+ColorSpawn.m
//  We all pay
//
//  Created by Mark Cornelisse on 16/08/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "UIColor+ColorSpawn.h"

unsigned int intFromHexString(NSString *hexString) {
    unsigned int hexInt = 0;

    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    BOOL success = [scanner scanHexInt:&hexInt];
    if (!success) {
        @throw [NSException exceptionWithName:@"Invalid hexString" reason:@"Unable to convert string to hex integer." userInfo:@{@"string": hexString}];
    }

    return hexInt;
}

UIColor * UIColorCreateFromHexString(NSString *hexString) {
    // Convert hex string to an integer
    unsigned int hexint = intFromHexString(hexString);
    
    CGFloat red = ((CGFloat) ((hexint & 0xFF0000) >> 16))/255;
    CGFloat green = ((CGFloat) ((hexint & 0x00FF00) >> 8))/255;
    CGFloat blue = ((CGFloat) (hexint & 0x0000FF))/255;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];

    return color;
}

UIColor * UIColorCreateFromHexStringAndAlpha(NSString *hexString, unsigned int alpha) {
    unsigned int hexint = intFromHexString(hexString);
    
    CGFloat red = ((CGFloat) ((hexint & 0xFF0000) >> 16))/255;
    CGFloat green = ((CGFloat) ((hexint & 0xFF00) >> 8))/255;
    CGFloat blue = ((CGFloat) (hexint & 0xFF))/255;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:((CGFloat) alpha)/100];

    return color;
}

@implementation UIColor (ColorSpawn)

+ (UIColor *)colorWithColorType:(MCColorType)type {
    switch (type) {
        case MCColorTypeBackground:
            return UIColorCreateFromHexString(@"#D5ECFD");
        case MCColorTypeButtonEnabled:
            return UIColorCreateFromHexString(@"#FF87AD");
        case MCColorTypeButtonDisabled:
            return UIColorCreateFromHexString(@"#FFDEE4");
        case MCColorTypeButtonHiglighted:
            return UIColorCreateFromHexStringAndAlpha(@"#FF87AD", 20);
        case MCColorTypeEmptyMessageText:
            return UIColorCreateFromHexString(@"#78A5C1");
        case MCColorTypeNavigationBar:
            return UIColorCreateFromHexString(@"#003366");
        default:
            @throw [NSException exceptionWithName:@"Invalid color" reason:@"The color type given is unknown." userInfo:@{@"colorType": @(type)}];
    }
}

@end
