//
//  InputHandler.h
//  RemoteKBMac
//
//  Created by everettjf on 2019/8/20.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class InputHandler;
@protocol InputHandlerDelegate <NSObject>

- (void)inputHandler:(InputHandler*)handler command:(NSString*)command content:(NSString*)content;

@end

@interface InputHandler : NSObject
@property (nonatomic, weak) id<InputHandlerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
