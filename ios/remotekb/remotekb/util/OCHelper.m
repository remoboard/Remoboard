//
//  OCHelper.m
//  remotekb
//
//  Created by everettjf on 2019/7/19.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "OCHelper.h"

@import AppCenter;
@import AppCenterAnalytics;
@import AppCenterCrashes;


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
    [MSAppCenter start:@"f983a7ea-5c81-49be-92e1-04a070a1b2da" withServices:@[
                                                                              [MSAnalytics class],
                                                                              [MSCrashes class]
                                                                              ]];

}

@end
