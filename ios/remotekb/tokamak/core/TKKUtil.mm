//
//  TKKUtil.m
//  Bumblebee
//
//  Created by everettjf on 2018/4/16.
//  Copyright © 2018年 everettjf. All rights reserved.
//

#import "TKKUtil.h"

NSString* TKK_FormatDate(NSDate* date){
    static NSDateFormatter *fmt;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmt = [[NSDateFormatter alloc]init];
        fmt.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    });
    return [fmt stringFromDate:date];
}

NSString* TKK_FormatDateYYYYMMDD(NSDate* date){
    static NSDateFormatter *fmt;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmt = [[NSDateFormatter alloc]init];
        fmt.dateFormat = @"yyyy-MM-dd";
    });
    return [fmt stringFromDate:date];
}
NSString* TKK_FormatDateMMDD(NSDate* date){
    static NSDateFormatter *fmt;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmt = [[NSDateFormatter alloc]init];
        fmt.dateFormat = @"MM-dd";
    });
    return [fmt stringFromDate:date];
}

void TKK_RangeDateForToday(NSDate** begin,NSDate** end){
    if(!begin || !end)return;
    
    NSDate *now = [NSDate date];
    TKK_RangeDateForDate(now, begin, end);
}

void TKK_RangeDateForDate(NSDate*theDate,NSDate** begin,NSDate** end){
    if(!begin || !end)return;

    NSDate *nowDay = TKK_DateBeginFromDate([NSDate date]);
    NSDate *nextDay = TKK_DateEndFromDate([NSDate date]);
    
    *begin = nowDay;
    *end = nextDay;
}

NSDate *TKK_DateBeginFromDate(NSDate* date){
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calender components:unitFlags fromDate:date];
    int hour = (int)[dateComponent hour];
    int minute = (int)[dateComponent minute];
    int second = (int)[dateComponent second];
    
    
    return [NSDate dateWithTimeInterval:- (hour*3600 + minute * 60 + second) sinceDate:date];
}

NSDate *TKK_DateEndFromDate(NSDate* date){
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calender components:unitFlags fromDate:date];
    int hour = (int)[dateComponent hour];
    int minute = (int)[dateComponent minute];
    int second = (int)[dateComponent second];
    
    return [NSDate dateWithTimeInterval:- (hour*3600 + minute * 60 + second)  + 86400 sinceDate:date];
}

NSArray<NSDate*>* TKK_LatestDays(NSUInteger days){
    NSDate *today = TKK_DateBeginFromDate([NSDate date]);
    NSMutableArray<NSDate*> *dates = [[NSMutableArray alloc]initWithCapacity:days];;
    for(NSUInteger i = 0; i < days; i++){
        NSUInteger d = days - i - 1; // if days = 7 ; then d = 6 5 4 3 2 1 0
        NSDate *thatDay = [NSDate dateWithTimeInterval:(-86400.0 * d) sinceDate:today];
        [dates addObject:thatDay];
    }
    return dates;
}

