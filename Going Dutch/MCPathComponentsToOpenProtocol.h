//
//  MCPathComponentsToOpenProtocol.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/11/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import CoreData;

NS_ASSUME_NONNULL_BEGIN

@protocol MCPathComponentsToOpenProtocol <NSObject>

- (void)prepareForUseWithPathComponentsToOpen:(NSArray<NSManagedObject *> *)pathComponentsToOpen NS_SWIFT_NAME(prepareForUse(with:));

@end

NS_ASSUME_NONNULL_END
