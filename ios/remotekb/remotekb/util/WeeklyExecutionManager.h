//
//  WeeklyExecutionManager.h
//  remotekb
//
//  Created by everettjf on 2024/1/6.
//  Copyright © 2024 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeeklyExecutionManager : NSObject

+ (instancetype)sharedManager;

- (void)executeBlock:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
