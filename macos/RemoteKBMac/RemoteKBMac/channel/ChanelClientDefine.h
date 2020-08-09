//
//  ChanelClientDefine.h
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/26.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, ChannelType) {
    ChannelType_IPNetwork,
    ChannelType_Bluetooth,
};

typedef NS_ENUM(NSUInteger, ChannelClientStatus) {
    // Common
    ChannelClientStatus_ConnectStart,
    ChannelClientStatus_ConnectStartConnected,
    ChannelClientStatus_ConnectStartShakeHands,
    ChannelClientStatus_ConnectReady,
    ChannelClientStatus_ConnectFailed,
    ChannelClientStatus_ConnectClose,
    
    // Bluetooth-specified
    ChannelClientStatus_Unsupported,
    ChannelClientStatus_PowerOff,
    ChannelClientStatus_Scanning,
    ChannelClientStatus_ServerList,
    
    // IPNetwork-specified
    // N/A
};
