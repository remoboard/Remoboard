//
//  ChannelServiceFactory.m
//  keyboard
//
//  Created by everettjf on 2019/7/21.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "ChannelServiceFactory.h"
#import "NetworkServerManager.h"
#import "BluetoothPeripheralManager.h"
#import "HttpServerManager.h"

#pragma mark -- HTTP


@interface HTTPChannelService : NSObject<ChannelService>
@property (nonatomic, weak) id<ChannelServiceDelegate> callback;
@end
@implementation HTTPChannelService

- (void)setDelegate:(nonnull id<ChannelServiceDelegate>)delegate {
    self.callback = delegate;
}

- (void)start {
    __weak typeof(self) ws = self;
    rekb::HttpServerManager::instance().onStatus = ^(const std::string &type,const std::string &data) {
        if(ws && ws.callback) {
            [ws.callback onStatus:[NSString stringWithUTF8String:type.c_str()] content:[NSString stringWithUTF8String:data.c_str()]];
        }
    };
    rekb::HttpServerManager::instance().onMessage = ^(const std::string &type,const std::string &data) {
        if(ws && ws.callback) {
            [ws.callback onMessage:[NSString stringWithUTF8String:type.c_str()] content:[NSString stringWithUTF8String:data.c_str()]];
        }
    };

    rekb::HttpServerManager::instance().start();
}

- (void)close {
    rekb::HttpServerManager::instance().close();
}

@end



#pragma mark -- IP Network

@interface IPNetworkChannelService : NSObject<ChannelService>
@property (nonatomic, weak) id<ChannelServiceDelegate> callback;
@end
@implementation IPNetworkChannelService

- (void)setDelegate:(nonnull id<ChannelServiceDelegate>)delegate {
    self.callback = delegate;
}

- (void)start {
    __weak typeof(self) ws = self;
    rekb::NetworkServerManager::instance().onConnectionCode = ^(const std::string &code,const std::string &ip) {
        if(ws && ws.callback) {
            [ws.callback onIPNetworkConnectionCode:[NSString stringWithUTF8String:code.c_str()] ip:[NSString stringWithUTF8String:ip.c_str()]];
        }
    };
    rekb::NetworkServerManager::instance().onStatus = ^(const std::string &type,const std::string &data) {
        if(ws && ws.callback) {
            [ws.callback onStatus:[NSString stringWithUTF8String:type.c_str()] content:[NSString stringWithUTF8String:data.c_str()]];
        }
    };
    rekb::NetworkServerManager::instance().onMessage = ^(const std::string &type,const std::string &data) {
        if(ws && ws.callback) {
            [ws.callback onMessage:[NSString stringWithUTF8String:type.c_str()] content:[NSString stringWithUTF8String:data.c_str()]];
        }
    };

    rekb::NetworkServerManager::instance().start();
}

- (void)close {
    rekb::NetworkServerManager::instance().close();
}

@end



#pragma mark -- Bluetooth
@interface BluetoothChannelService : NSObject<ChannelService>
@property (nonatomic, weak) id<ChannelServiceDelegate> callback;

@end
@implementation BluetoothChannelService

- (void)setDelegate:(nonnull id<ChannelServiceDelegate>)delegate {
    self.callback = delegate;
}

- (void)start {
    [BluetoothPeripheralManager sharedManager].onReady = ^(NSString *serverName) {
        if(self.callback) {
            [self.callback onBluetoothServerName:serverName];
        }
    };
    [BluetoothPeripheralManager sharedManager].onStatus = ^(NSString *type, NSString *content) {
        if(self.callback) {
            [self.callback onStatus:type content:content];
        }
    };
    [BluetoothPeripheralManager sharedManager].onMessage = ^(NSString *type, NSString *content) {
        if(self.callback) {
            [self.callback onMessage:type content:content];
        }
    };
    
    [[BluetoothPeripheralManager sharedManager] start];
}

- (void)close {
    [[BluetoothPeripheralManager sharedManager] close];
}

@end


@implementation ChannelServiceFactory

+ (id<ChannelService>)createChannel:(NSString*)channelType {
    if ([channelType isEqualToString:@"bluetooth"]) {
        return [[BluetoothChannelService alloc] init];
    } else if ([channelType isEqualToString:@"ipnetwork"]) {
        return [[IPNetworkChannelService alloc] init];
    } else if ([channelType isEqualToString:@"http"]) {
        return [[HTTPChannelService alloc] init];
    } else {
        NSLog(@"Unknown channel type");
    }
    return nil;
}

@end
