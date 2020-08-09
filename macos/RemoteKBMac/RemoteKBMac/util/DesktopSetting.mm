//
//  DesktopSetting.m
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/22.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "DesktopSetting.h"

@implementation DesktopSetting

+ (instancetype)sharedSetting {
    static DesktopSetting *o;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        o = [[DesktopSetting alloc]init];
    });
    return o;
}

- (BOOL)bluetoothSelected {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"bluetooth-selected"];
}

- (void)setBluetoothSelected:(BOOL)selected {
    [[NSUserDefaults standardUserDefaults] setBool:selected forKey:@"bluetooth-selected"];
}

- (InputMode)inputMode {
    NSInteger mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"input-mode"];
    return (InputMode)mode;
}

- (void)setInputMode:(InputMode)inputMode {
    [[NSUserDefaults standardUserDefaults] setInteger:inputMode forKey:@"input-mode"];
}

- (NSString *)connectionCode {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"last-connection-code"];
}

- (void)setConnectionCode:(NSString *)connectionCode {
    [[NSUserDefaults standardUserDefaults] setObject:connectionCode forKey:@"last-connection-code"];
}

- (BOOL)autoReconnectWhenDisconnected {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"autoReconnectWhenDisconnected"];
}

- (void)setAutoReconnectWhenDisconnected:(BOOL)autoReconnectWhenDisconnected {
    [[NSUserDefaults standardUserDefaults] setBool:autoReconnectWhenDisconnected forKey:@"autoReconnectWhenDisconnected"];
}

- (BOOL)autoConnectWhenAppStartup {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"autoConnectWhenAppStartup"];
}

- (void)setAutoConnectWhenAppStartup:(BOOL)autoConnectWhenAppStartup {
    [[NSUserDefaults standardUserDefaults] setBool:autoConnectWhenAppStartup forKey:@"autoConnectWhenAppStartup"];
}

@end
