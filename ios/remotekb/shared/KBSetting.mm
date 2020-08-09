//
//  KBSetting.m
//  keyboard
//
//  Created by everettjf on 2019/7/21.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "KBSetting.h"
#import "PAAUI.h"

@interface KBSetting ()
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation KBSetting


+ (instancetype)sharedSetting {
    static KBSetting *o;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        o = [[KBSetting alloc] init];
    });
    return o;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.everettjf.remotekb"];
    }
    return self;
}

- (NSString *)lastAppVersion {
    return [self.userDefaults stringForKey:@"AppVersion"];
}

- (void)setLastAppVersion:(NSString *)lastAppVersion {
    [self.userDefaults setObject:lastAppVersion forKey:@"AppVersion"];
}

- (KBConnectMode)connectMode {
    NSInteger mode = [self.userDefaults integerForKey:@"ConnectMode"];
    return (KBConnectMode)mode;
}

- (void)setConnectMode:(KBConnectMode)connectMode {
    [self.userDefaults setInteger:connectMode forKey:@"ConnectMode"];
}

- (NSArray<NSString*> *)readWords {
    NSArray<NSString*> * res = [self.userDefaults objectForKey:@"QuickWords"];
    if (res == nil) {
        return @[];
    }
    return res;
}

- (void)writeWords:(NSArray<NSString*>*)words {
    [self.userDefaults setObject:words forKey:@"QuickWords"];
}

- (void)addWord:(NSString*)word {
    NSMutableArray* words = [[self readWords] mutableCopy];
    [words addObject:word];
    [self writeWords:words];
}

- (void)removeWord:(NSString*)word {
    NSMutableArray* words = [[self readWords] mutableCopy];
    [words removeObject:word];
    [self writeWords:words];
}

- (void)resetDefaultWords {
    
    
    NSArray *words;
    ttt_zhcn;
    if (hasLang) {
        words = @[
                  @"好的",
                  @"收到",
                  @"搞定",
                  @"先转后看",
                  @"一会儿见",
                  @"赞",
                  ];
    } else {
        words = @[
                  @"OK :)",
                  @"Got it.",
                  @"Done :)",
                  @"Read later",
                  @"See you later",
                  ];
    }
    


    [[KBSetting sharedSetting] writeWords:words];
}

@end
