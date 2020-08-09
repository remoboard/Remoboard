//
//  ChannelClientFactory.m
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/22.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "ChannelClientFactory.h"
#import "NetworkClientManager.h"
#import "BluetoothCentralManager.h"

#pragma mark IP Network

@interface ChannelNetworkClient : NSObject <ChannelClient>
@property (nonatomic, weak) id<ChannelClientDelegate> callback;
@end

@implementation ChannelNetworkClient

- (void)setDelegate:(nonnull id<ChannelClientDelegate>)delegate {
    self.callback = delegate;
}
- (void)start {
    
}
- (void)connect:(nonnull NSString*)host {
    if (host.length == 0) {
        return;
    }
    
    __weak typeof(self) ws = self;
    rekb::NetworkClientManager::instance().onStatus = ^(ChannelClientStatus type, const std::string & data) {
        if(ws && ws.callback) {
            NSString *content = [NSString stringWithUTF8String:data.c_str()];
            [ws.callback onChannel:ChannelType_IPNetwork status:type content:content data:nil];
        }
    };
    rekb::NetworkClientManager::instance().onMessage = ^(const std::string & type, const std::string & data) {
        if(ws && ws.callback) {
            if ([ws.callback respondsToSelector:@selector(onChannel:command:content:data:)]) {
                NSString *command = [NSString stringWithUTF8String:type.c_str()];
                NSString *content = [NSString stringWithUTF8String:data.c_str()];
                [ws.callback onChannel:ChannelType_IPNetwork command:command content:content data:nil];
            }
        }
    };
    
    rekb::NetworkClientManager::instance().setHost(host.UTF8String);
    rekb::NetworkClientManager::instance().connect();
}

- (void)send:(nonnull NSString *)type content:(nonnull NSString *)content {
    rekb::NetworkClientManager::instance().send(type.UTF8String, content.UTF8String);
}
- (void)close {
    rekb::NetworkClientManager::instance().close();
}
@end


#pragma mark Bluetooth


@interface ChannelBluetoothClient : NSObject <ChannelClient>
@property (nonatomic, weak) id<ChannelClientDelegate> callback;

@end

@implementation ChannelBluetoothClient

- (void)setDelegate:(nonnull id<ChannelClientDelegate>)delegate {
    self.callback = delegate;
}
- (void)start {
    __weak typeof(self) ws = self;
    [BluetoothCentralManager sharedManager].onScanResult = ^(NSArray<NSString *> * _Nonnull items) {
        if(ws && ws.callback) {
            NSDictionary *data = @{
                                   @"names":items
                                   };
            [ws.callback onChannel:ChannelType_Bluetooth status:ChannelClientStatus_ServerList content:@"" data:data];
        }
    };
    [BluetoothCentralManager sharedManager].onStatus = ^(ChannelClientStatus type, NSString * _Nonnull content) {
        if(ws && ws.callback) {
            [ws.callback onChannel:ChannelType_Bluetooth status:type content:content data:nil];
        }
    };
}
- (void)connect:(nonnull NSString*)host {
    if (host.length == 0) {
        return;
    }

    [[BluetoothCentralManager sharedManager] connect:host];
}

- (void)send:(nonnull NSString *)type content:(nonnull NSString *)content {
    [[BluetoothCentralManager sharedManager] send:type content:content];
}

- (void)close {
    [[BluetoothCentralManager sharedManager] close];
}

@end

@implementation ChannelClientFactory

+ (id<ChannelClient>)createClient:(ChannelType)type {
    switch (type) {
        case ChannelType_IPNetwork:
            return [[ChannelNetworkClient alloc] init];
        case ChannelType_Bluetooth:
            return [[ChannelBluetoothClient alloc] init];
            break;
        default:
            NSLog(@"Unknown type");
            return nil;
    }
}

@end
