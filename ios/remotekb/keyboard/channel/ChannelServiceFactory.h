//
//  ChannelServiceFactory.h
//  keyboard
//
//  Created by everettjf on 2019/7/21.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol ChannelServiceDelegate <NSObject>

/**
 remote type and content
 */
- (void)onMessage:(NSString*)type content:(NSString*)content;
/**
 waiting
 connected
 disconnected
 */
- (void)onStatus:(NSString*)identifier content:(NSString*)content;

/**
 IPNetwork specified
 */
- (void)onIPNetworkConnectionCode:(NSString*)code ip:(NSString*)ip;
/**
 Bluetooth specified
 */
- (void)onBluetoothServerName:(NSString*)name;

@end

@protocol ChannelService <NSObject>

- (void)setDelegate:(id<ChannelServiceDelegate>)delegate;
- (void)start;
- (void)close;

@end

@interface ChannelServiceFactory : NSObject

+ (id<ChannelService>)createChannel:(NSString*)channelType;

@end

NS_ASSUME_NONNULL_END
