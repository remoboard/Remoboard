//
//  TinyKeyboardView.h
//  QVKeyboard
//
//  Created by everettjf on 2018/10/19.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PAA_SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define PAA_SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)

#define PAA_RGB(r, g, b)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]

#define PAA_RGBHEX(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define PAA_STATUS_BAR_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)

#define PAA_ATTRIBUTE_STRING(text,color,font) \
[[NSAttributedString alloc]initWithString:text \
attributes:@{ NSForegroundColorAttributeName: color, NSFontAttributeName: font }];



NS_ASSUME_NONNULL_BEGIN


#define TinyKeyboardViewColor1 PAA_RGB(171,175,186);
#define TinyKeyboardViewColor2 PAA_RGB(208,210,217);


@class TinyKeyboardView;

@protocol TinyKeyboardViewDelegate <NSObject>

@required
- (void)TinyKeyboardView:(TinyKeyboardView*)keyboardView characterTapped:(NSString*)character;
- (void)TinyKeyboardView:(TinyKeyboardView*)keyboardView specialTapped:(NSString*)type;

@end

@interface TinyKeyboardView : UIView

@property (nonatomic, weak) id<TinyKeyboardViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
