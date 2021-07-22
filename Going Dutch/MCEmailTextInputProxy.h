//
//  MCEmailTextInputProxy.h
//  We all pay
//
//  Created by Mark Cornelisse on 07/11/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

@import Foundation;

@class MCEmailTextInputValidator;
@class MCEmailTextInputPicker;

typedef NS_ENUM(NSInteger, MCEmailTextInputProxyTarget) {
    MCEmailTextInputProxyTargetValidator,
    MCEmailTextInputProxyTargetPicker
} NS_SWIFT_NAME(EmailTextInputProxy.Target);

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(EmailTextInputProxy)
__attribute__((objc_subclassing_restricted))
@interface MCEmailTextInputProxy : NSProxy <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic) MCEmailTextInputProxyTarget target;

- (instancetype)initWithValidator:(MCEmailTextInputValidator *)validator andPicker:(MCEmailTextInputPicker *)picker andTarget:(MCEmailTextInputProxyTarget)target;

@end

NS_ASSUME_NONNULL_END
