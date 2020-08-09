//
//  Util.h
//  keyboard
//
//  Created by everettjf on 2019/6/21.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Util : NSObject

+ (NSString *)currentIPAddress;
+ (NSString *)ipAddress2ConnectionCode:(NSString*)ipaddress;

+ (void)impactOccurred;



@end

NS_ASSUME_NONNULL_END
