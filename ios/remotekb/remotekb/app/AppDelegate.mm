//
//  AppDelegate.m
//  remotekb
//
//  Created by everettjf on 2019/6/16.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "AppDelegate.h"
#import "OCHelper.h"
#import "KBSetting.h"
#import "AppUtil.h"
#import "AppMemoryData.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *currentAppVersion = [AppUtil getAppVersion];
    NSString *lastAppVersion = [KBSetting sharedSetting].lastAppVersion;
    if (lastAppVersion.length == 0
        || (![lastAppVersion isEqualToString:currentAppVersion])) {
        // version changed
        [AppMemoryData shared].isNewVersionFirstLaunch = YES;
    }
    // write current version
    [KBSetting sharedSetting].lastAppVersion = currentAppVersion;
    
    [[OCHelper shared] didFinishLaunching];


    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if (url && url.query.length > 0) {
        NSDictionary *params = [self dictionaryFromQuery:url.query];
        
        NSString *handoffUrl = [params objectForKey:@"handoff"];
        if (handoffUrl.length > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HandoffUrl" object:handoffUrl];
            });
        }
    }
    return YES;
}

- (NSDictionary*)dictionaryFromQuery:(NSString*)query
{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString* value = [[kvPair objectAtIndex:1] stringByRemovingPercentEncoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}
    
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
