//
//  Utils.h
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/18.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>


// localization

#define ttt(key) \
[NSBundle.mainBundle localizedStringForKey:(key) value:@"" table:nil]

#define ttt_lang(lang) \
NSArray *languages = [NSLocale preferredLanguages]; \
NSString *language = [languages objectAtIndex:0]; \
BOOL hasLang = [language hasPrefix:lang];

#define ttt_zhcn ttt_lang(@"zh")



NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (NSString*)connectionCode2IpAddress:(NSString*)code;

@end

NS_ASSUME_NONNULL_END
