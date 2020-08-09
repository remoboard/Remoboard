//
//  AppMemoryData.h
//  remotekb
//
//  Created by everettjf on 2019/10/12.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppMemoryData : NSObject

+ (instancetype)shared;

@property (nonatomic, assign) BOOL isNewVersionFirstLaunch;

@end

NS_ASSUME_NONNULL_END
