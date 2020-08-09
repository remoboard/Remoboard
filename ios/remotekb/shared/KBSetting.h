//
//  KBSetting.h
//  keyboard
//
//  Created by everettjf on 2019/7/21.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KBConnectMode) {
KBConnectMode_HTTP = 0, // Default For New Version
    KBConnectMode_IP = 1,
    KBConnectMode_BLE = 2,
};

@interface KBSetting : NSObject

+ (instancetype)sharedSetting;

@property (nonatomic, assign) KBConnectMode connectMode;

- (NSArray<NSString*> *)readWords;
- (void)writeWords:(NSArray<NSString*>*)words;
- (void)addWord:(NSString*)word;
- (void)removeWord:(NSString*)word;
- (void)resetDefaultWords;

@property (nonatomic, strong) NSString *lastAppVersion;

@end

NS_ASSUME_NONNULL_END
