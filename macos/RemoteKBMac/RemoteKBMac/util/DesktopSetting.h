//
//  DesktopSetting.h
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/22.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, InputMode) {
    InputModeStandard = 0,
    InputModeMultiline = 1,
    InputModeImmediate = 3,
};


@interface DesktopSetting : NSObject

+ (instancetype)sharedSetting;

@property (nonatomic, assign) BOOL bluetoothSelected;
@property (nonatomic, assign) InputMode inputMode;
@property (nonatomic, strong) NSString* connectionCode;

@property (nonatomic, assign) BOOL autoReconnectWhenDisconnected;
@property (nonatomic, assign) BOOL autoConnectWhenAppStartup;

@end

NS_ASSUME_NONNULL_END
