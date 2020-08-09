//
//  Util.m
//  keyboard
//
//  Created by everettjf on 2019/6/21.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "Util.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#include "../../dep/logic/anybase.h"
#import <UIKit/UIKit.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"



@implementation Util

+ (void)impactOccurred {
    
    UIImpactFeedbackGenerator *feedBackGenertor = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [feedBackGenertor impactOccurred];
}


+ (NSString*)ipAddress2ConnectionCode:(NSString*)ipaddress {
    NSArray<NSString*>* parts = [ipaddress componentsSeparatedByString:@"."];
    if ([parts count] != 4) {
        // invalid ip address
        return @"";
    }
    
    NSInteger n0 = parts[0].integerValue;
    NSInteger n1 = parts[1].integerValue;
    NSInteger n2 = parts[2].integerValue;
    NSInteger n3 = parts[3].integerValue;
    
    if(n0 == 192 && n1 == 168) {
        // 192.168.?.?
        // ->
        // x??
        long codeBase10 =
        n2 * 256 +
        n3;
        
        std::string codeBase36 = anybase::Decimal2AnyBase(codeBase10, 32);
        return [NSString stringWithFormat:@"x%s",codeBase36.c_str()];
    } else {
        long codeBase10 = n0 * 256 * 256 * 256 +
        n1 * 256 * 256 +
        n2 * 256 +
        n3;
        
        std::string codeBase36 = anybase::Decimal2AnyBase(codeBase10, 32);
        return [NSString stringWithFormat:@"%s",codeBase36.c_str()];
    }
}

+ (NSString*)currentConnectionCode {
    return [Util ipAddress2ConnectionCode:[Util currentIPAddress]];
}

+ (NSString *)currentIPAddress
{
    NSString *ipv4key = IOS_WIFI @"/" IP_ADDR_IPv4;
    NSDictionary *alladdress = [Util getAllIPAddress];
    NSString *address = [alladdress objectForKey:ipv4key];
    if(!address) {
        return @"";
    }
    return address;
}

+ (NSDictionary *)getAllIPAddress
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
