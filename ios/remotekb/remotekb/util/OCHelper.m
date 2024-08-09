//
//  OCHelper.m
//  remotekb
//
//  Created by everettjf on 2019/7/19.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "OCHelper.h"


@implementation OCHelper

+ (instancetype)shared {
    static OCHelper *o;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        o = [[OCHelper alloc] init];
    });
    return o;
}

- (void)didFinishLaunching {
    
}

@end
