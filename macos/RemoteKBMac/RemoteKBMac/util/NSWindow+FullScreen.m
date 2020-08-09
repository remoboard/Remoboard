//
//  NSWindow+FullScreen.m
//  RemoteKBMac
//
//  Created by everettjf on 2019/8/20.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "NSWindow+FullScreen.h"

@implementation NSWindow (FullScreen)

- (BOOL)rekb_isFullScreen
{
    return (([self styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask);
}

@end
