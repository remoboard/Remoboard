//
//  TKKApp.h
//  Bumblebee
//
//  Created by everettjf on 2018/4/9.
//  Copyright © 2018年 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKKApp : NSObject
@property (nonatomic,assign) BOOL firstRunAfterInstall;
//@property (nonatomic,assign) BOOL firstRunAfterUpgrade;

+ (instancetype)shared;

+ (NSString*)documentPath;
+ (NSString*)tmpPath;
+ (NSString*)homePath;

@end
