//
//  ImmediateInputHandler.h
//  RemoteKBMac
//
//  Created by everettjf on 2019/8/19.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "InputHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImmediateInputHandler : InputHandler <NSTextFieldDelegate,NSTextFieldDelegate>

@property (nonatomic, weak) NSTextField *textField;

@end

NS_ASSUME_NONNULL_END
