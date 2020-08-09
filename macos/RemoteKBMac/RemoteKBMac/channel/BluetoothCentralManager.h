//
//  BluetoothCentralManager.h
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/20.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ChanelClientDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface BluetoothCentralManager : NSObject

@property (strong) void(^onScanResult)(NSArray<NSString*>*items);
@property (strong) void(^onStatus)(ChannelClientStatus type,NSString*content);
//@property (strong) void (^onMessage)(NSString* command, NSString* data);

+ (instancetype)sharedManager;

- (void)start;
- (void)connect:(NSString*)peripheralName;
- (void)send:(NSString*)type content:(NSString*)content;
- (void)close;

@end

NS_ASSUME_NONNULL_END
