//
//  Utils.m
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/18.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "Utils.h"
#include "../../dep/logic/anybase.h"

@implementation Utils

+ (NSString*)connectionCode2IpAddress:(NSString*)code {
    if (code.length == 0) {
        return @"";
    }
    NSString *codelowercase = [[code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    if ([[codelowercase substringToIndex:1] isEqualToString:@"x"]) {
        // x??
        // ->
        // 192.168.?.?
        NSString *substring = [codelowercase substringFromIndex:1];
        
        long decimalCode = anybase::AnyBase2Decimal(substring.UTF8String, 32);
        if (decimalCode == -1) {
            NSLog(@"invalid code");
            return @"";
        }
        long p3 = (decimalCode >> 8) & 0xff;
        long p4 = (decimalCode) & 0xff;
        return [NSString stringWithFormat:@"192.168.%@.%@",@(p3),@(p4)];
    } else {
        long decimalCode = anybase::AnyBase2Decimal(codelowercase.UTF8String, 32);
        if (decimalCode == -1) {
            NSLog(@"invalid code");
            return @"";
        }
        return [Utils decimal2IpAddress:decimalCode];
    }
}

+ (NSString*)decimal2IpAddress:(long)code {
    long p1 = (code >> 24) & 0xff;
    long p2 = (code >> 16) & 0xff;
    long p3 = (code >> 8) & 0xff;
    long p4 = (code) & 0xff;
    
    return [NSString stringWithFormat:@"%@.%@.%@.%@",@(p1),@(p2),@(p3),@(p4)];
}

@end
