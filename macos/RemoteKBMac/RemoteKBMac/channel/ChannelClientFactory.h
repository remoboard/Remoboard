//
//  ChannelClientFactory.h
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/22.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ChanelClientDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChannelClientDelegate <NSObject>

- (void)onChannel:(ChannelType)channelType status:(ChannelClientStatus)statusType content:(NSString*)content data:(nullable NSDictionary*)data;

@optional
- (void)onChannel:(ChannelType)channelType command:(NSString*)command content:(NSString*)content data:(nullable NSDictionary*)data;

@end

@protocol ChannelClient <NSObject>

- (void)setDelegate:(id<ChannelClientDelegate>)delegate;
- (void)start;
- (void)connect:(NSString*)host;
- (void)send:(NSString*)type content:(NSString*)content;
- (void)close;

@end

@interface ChannelClientFactory : NSObject

+ (id<ChannelClient>)createClient:(ChannelType)type;

@end

NS_ASSUME_NONNULL_END
