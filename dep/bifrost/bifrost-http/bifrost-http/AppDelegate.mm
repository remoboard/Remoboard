//
//  AppDelegate.m
//  bifrost-http
//
//  Created by everettjf on 2019/9/26.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "AppDelegate.h"
#import "../../bifrost/http/httpserver.hpp"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    NSString *siteRoot = [[NSBundle mainBundle] pathForResource:@"site" ofType:@"bundle"];
    NSLog(@"siteroot = %@",siteRoot);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        bifrost::HttpServer::instance().set_port("777");
        bifrost::HttpServer::instance().set_root_dir(siteRoot.UTF8String);
        bifrost::HttpServer::instance().onMessage = [&](const std::string & msg) {
//            printf("receive = %s\n", msg.c_str());
        };
         
        bifrost::HttpServer::instance().run();
    });
    
    return YES;
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
