//
//  TKKUtil.h
//  Bumblebee
//
//  Created by everettjf on 2018/4/16.
//  Copyright © 2018年 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>


#if defined(__cplusplus)
extern "C" {
#endif
    
    // Introduce Swift let
    #pragma mark - Swift let
    #ifdef __cplusplus
    #define let const auto
    #else
    #define let const __auto_type
    #endif
    
    // Introduce Swift var
    #pragma mark - Swift var
    #ifdef __cplusplus
    #define var auto
    #else
    #define var __auto_type
    #endif
    
//    // Introduce Swift defer
//    #pragma mark - Swift defer
//    typedef void (^defer_block_t)(void);
//
//    #pragma clang diagnostic push
//    #pragma clang diagnostic ignored "-Wunused-function"
//    static inline void cleanup(__strong defer_block_t *block) {
//        (*block)();
//    }
//    #pragma clang diagnostic pop
//
//    #define defer_block(id) \
//    defer_block ## id
//
//    #define defer_at(line) \
//    defer_block(line)
//
//    #define defer \
//    __strong defer_block_t defer_at(__LINE__) \
//    __attribute__((cleanup(cleanup), unused)) = ^
//
    
    // C++ Singleton
    #if defined(__cplusplus)
    #define TKK_SINGLETON_CLASS(ClassName)\
    private:\
    ClassName(){}\
    public:\
    static ClassName & Instance(){ \
    static ClassName o; \
        return o; \
    }
    #endif

#if defined(__cplusplus)
}
#endif



NSString* TKK_FormatDate(NSDate* date);
NSString* TKK_FormatDateYYYYMMDD(NSDate* date);
NSString* TKK_FormatDateMMDD(NSDate* date);

void TKK_RangeDateForToday(NSDate** begin,NSDate** end);
void TKK_RangeDateForDate(NSDate*theDate,NSDate** begin,NSDate** end);

NSDate *TKK_DateBeginFromDate(NSDate* date);
NSDate *TKK_DateEndFromDate(NSDate* date);

NSArray<NSDate*>* TKK_LatestDays(NSUInteger days);

