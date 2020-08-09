//
//  PAAUI.h
//  Bumblebee
//
//  Created by everettjf on 2018/4/29.
//  Copyright © 2018年 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define PAA_SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define PAA_SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)

#define PAA_RGB(r, g, b)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]

#define PAA_RGBHEX(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
    green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
    blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
    alpha:1.0]

#define PAA_RGBHEX_ALPHA(rgbValue,alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
    green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
    blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
    alpha:alphaValue]

#define PAA_STATUS_BAR_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)

#define PAA_ATTRIBUTE_STRING(text,color,font) \
    [[NSAttributedString alloc]initWithString:text \
    attributes:@{ NSForegroundColorAttributeName: color, NSFontAttributeName: font }];


// localization

#define ttt(key) \
[NSBundle.mainBundle localizedStringForKey:(key) value:@"" table:nil]

#define ttt_lang(lang) \
    NSArray *languages = [NSLocale preferredLanguages]; \
    NSString *language = [languages objectAtIndex:0]; \
    BOOL hasLang = [language hasPrefix:lang];

#define ttt_zhcn ttt_lang(@"zh")
