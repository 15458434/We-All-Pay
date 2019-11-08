//
//  MCEmailTextInputProxy.m
//  We all pay
//
//  Created by Mark Cornelisse on 07/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

#import "MCEmailTextInputProxy.h"

#import "We_all_pay-Swift.h"

@interface MCEmailTextInputProxy ()

@property (nonatomic, strong, readonly) MCEmailTextInputValidator *validator;
@property (nonatomic, strong, readonly) MCEmailTextInputPicker *picker;

@end

@implementation MCEmailTextInputProxy

- (instancetype)initWithValidator:(MCEmailTextInputValidator *)validator andPicker:(MCEmailTextInputPicker *)picker andTarget:(MCEmailTextInputProxyTarget)target {
    _validator = validator;
    _picker = picker;
    _picker.textField.delegate = self;
    _target = MCEmailTextInputProxyTargetPicker;
    return self;
}

#pragma mark - NSProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    switch (_target) {
        case MCEmailTextInputProxyTargetValidator:
            return [_validator methodSignatureForSelector:sel];
            break;
        case MCEmailTextInputProxyTargetPicker:
            return [_picker methodSignatureForSelector:sel];
            break;
        default:
            NSAssert(NO, @"Unknown proxy target.");
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    switch (_target) {
        case MCEmailTextInputProxyTargetValidator:
            [invocation invokeWithTarget:_validator];
            break;
        case MCEmailTextInputProxyTargetPicker:
            [invocation invokeWithTarget:_picker];
            break;
        default:
            NSAssert(NO, @"Unknown proxy target.");
    }
}

@end
