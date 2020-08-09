//
//  AppUtil.m
//  remotekb
//
//  Created by everettjf on 2019/10/12.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "AppUtil.h"
#import <UIKit/UIKit.h>

@implementation AppUtil
+ (NSString*)getAppVersion {
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@.%@",shortVersion,buildVersion];
    return appVersion;
}

+ (void)openSetting {
    NSURL *settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:settingUrl options:@{} completionHandler:^(BOOL success) {}];
}

@end
