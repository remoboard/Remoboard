//
//  AppMemoryData.m
//  remotekb
//
//  Created by everettjf on 2019/10/12.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "AppMemoryData.h"

@implementation AppMemoryData

+ (instancetype)shared {
    static AppMemoryData *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[AppMemoryData alloc] init];
    });
    return obj;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isNewVersionFirstLaunch = NO;
    }
    return self;
}


@end
