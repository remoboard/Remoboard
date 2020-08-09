//
//  ImmediateInputHandler.m
//  RemoteKBMac
//
//  Created by everettjf on 2019/8/19.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "ImmediateInputHandler.h"

@interface ImmediateInputHandler ()

@end

@implementation ImmediateInputHandler

- (void)controlTextDidChange:(NSNotification *)obj {
    NSString *curText = self.textField.stringValue;

    if (![curText isEqualToString:@""]) {
        [self onCommand:@"input" content:curText];

        self.textField.stringValue = @"";
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
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

    return NO;
}

- (void)onCommand:(NSString*)command content:(NSString*)content {
    if (self.delegate) {
        [self.delegate inputHandler:self command:command content:content];
    }
}


@end
