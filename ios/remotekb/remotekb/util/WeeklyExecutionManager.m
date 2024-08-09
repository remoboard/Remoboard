//
//  WeeklyExecutionManager.m
//  remotekb
//
//  Created by everettjf on 2024/1/6.
//  Copyright © 2024 everettjf. All rights reserved.
//

#import "WeeklyExecutionManager.h"

@implementation WeeklyExecutionManager

+ (instancetype)sharedManager {
    static WeeklyExecutionManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)executeBlock:(void (^)(void))block {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastExecutionDate = [defaults objectForKey:@"LastExecutionDate"];
    NSDate *currentDate = [NSDate date];
    
    if (!lastExecutionDate) {
        // If it's the first time, record the current date and return without executing the block.
        [defaults setObject:currentDate forKey:@"LastExecutionDate"];
    } else {
        // Check if 7 days have passed since the last execution.
        NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:lastExecutionDate];
        if (timeInterval >= (7 * 24 * 60 * 60)) {
            [defaults setObject:currentDate forKey:@"LastExecutionDate"];
            
            if (block) {
                block();
            }
        }
    }
}

@end
