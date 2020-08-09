//
//  StandardInputHandler.m
//  RemoteKBMac
//
//  Created by everettjf on 2019/8/19.
//  Copyright © 2019 everettjf. All rights reserved.
//


#import "StandardInputHandler.h"

@interface StandardInputHandler ()

@end

@implementation StandardInputHandler


- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    
    if (self.textField.stringValue.length == 0) {
        // 当没有内容时，按照这样的策略
        if (commandSelector == @selector(deleteBackward:)) {
            [self onCommand:@"input-delete" content:@""];
        } else if (commandSelector == @selector(insertNewline:)) {
            [self onCommand:@"input" content:@"\n"];
        } else if (commandSelector == @selector(moveLeft:)) {
            [self onCommand:@"move-left" content:@""];
        } else if (commandSelector == @selector(moveRight:)) {
            [self onCommand:@"move-right" content:@""];
        } else if (commandSelector == @selector(moveUp:)) {
            [self onCommand:@"move-up" content:@""];
        } else if (commandSelector == @selector(moveDown:)) {
            [self onCommand:@"move-down" content:@""];
        } else {
            NSLog(@"doCommandBySelector %@",NSStringFromSelector(commandSelector));
        }
    } else {
        // 当有内容时，仅响应回车
        if (commandSelector == @selector(insertNewline:)) {
            [self onCommand:@"input" content:self.textField.stringValue];
            
            self.textField.stringValue = @"";
        }
    }

    return NO;
}

- (void)onCommand:(NSString*)command content:(NSString*)content {
    if (self.delegate) {
        [self.delegate inputHandler:self command:command content:content];
    }
}

@end
