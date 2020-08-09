//
//  BluetoothPeripheralManager.h
//  keyboard
//
//  Created by everettjf on 2019/7/20.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BluetoothPeripheralManager : NSObject


@property (nonatomic,strong) void (^onReady)(NSString* serverName);
@property (nonatomic,strong) void (^onStatus)(NSString* type, NSString* data);
@property (nonatomic,strong) void (^onMessage)(NSString* type, NSString* data);

+ (instancetype)sharedManager;

- (void)start;

- (void)close;

@end

NS_ASSUME_NONNULL_END
