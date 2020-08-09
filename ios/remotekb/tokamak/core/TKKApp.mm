//
//  TKKApp.m
//  Bumblebee
//
//  Created by everettjf on 2018/4/9.
//  Copyright © 2018年 everettjf. All rights reserved.
//

#import "TKKApp.h"

@implementation TKKApp

+ (NSString *)documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if(paths.count == 0)
        return @"";
    return paths[0];
}

+ (NSString*)tmpPath{
    return NSTemporaryDirectory();
}

+ (NSString*)homePath{
    return NSHomeDirectory();
}

+ (instancetype)shared{
    static TKKApp *o;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        o = [[TKKApp alloc]init];
    });
    return o;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
        
        static NSString *const kInstallKey = @"TKK_RunAfterInstall";
        BOOL installed = [config boolForKey:kInstallKey];
        if(installed){
            _firstRunAfterInstall = NO;
        }else{
            _firstRunAfterInstall = YES;
            [config setBool:YES forKey:kInstallKey];
            [config synchronize];
        }
        
    }
    return self;
}


@end
