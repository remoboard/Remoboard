//
//  ViewController.m
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/16.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "ViewController.h"
#import "Utils.h"
#import "ChannelClientFactory.h"
#import "DesktopSetting.h"
#import <pthread.h>
#import "GoogleAnalyticsTracker.h"
#import "ImmediateInputHandler.h"
#import "StandardInputHandler.h"

@interface ViewController() <ChannelClientDelegate, InputHandlerDelegate>

@property (weak) IBOutlet NSTabView *tabViewChannel;
@property (weak) IBOutlet NSTabView *tabViewInput;

@property (weak) IBOutlet NSTextField *textFieldStandard;
@property (unsafe_unretained) IBOutlet NSTextView *textViewMultiline;
@property (weak) IBOutlet NSTextField *textFieldImmediate;

@property (weak) IBOutlet NSTextField *textFieldConnCode;
@property (weak) IBOutlet NSPopUpButton *popupButtonBluetoothList;

@property (weak) IBOutlet NSButton *buttonConnect;
@property (weak) IBOutlet NSTextField *textFieldStatus;

@property (strong) id<ChannelClient> client;
@property (assign) BOOL isButtonConnect;
@property (assign) BOOL isConnectionReadyNow;

@property (strong) ImmediateInputHandler *immediateInputHandler;
@property (strong) StandardInputHandler *standardInputHandler;

@property (assign) BOOL onceConnectSucceed; // 当前进程期间连接成功过
@property (strong) NSTimer *heartBeatTimer;
@property (assign) CFTimeInterval pongTimestamp;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.onceConnectSucceed = NO;
    
    // init ui
    [self.popupButtonBluetoothList removeAllItems];
    
    self.immediateInputHandler = [[ImmediateInputHandler alloc] init];
    self.immediateInputHandler.delegate = self;
    self.immediateInputHandler.textField = self.textFieldImmediate;
    self.textFieldImmediate.delegate = self.immediateInputHandler;

    
    self.standardInputHandler = [[StandardInputHandler alloc] init];
    self.standardInputHandler.delegate = self;
    self.standardInputHandler.textField = self.textFieldStandard;
    self.textFieldStandard.delegate = self.standardInputHandler;
    
    [self onConnectChannelStaticStatusInit];
    
    // init channel
    [self loadChanelClient];
    
    [self reloadChannelLayout];
    [self reloadInputModeLayout];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"channel-changed" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self loadChanelClient];
        [self reloadChannelLayout];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"input-mode-changed" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self reloadInputModeLayout];
    }];
    
    [self loadSavedConnectionCode];
    [self checkAutoStartTask];
}

- (void)initAnalytics {
    MPAnalyticsConfiguration *configuration = [[MPAnalyticsConfiguration alloc] initWithAnalyticsIdentifier:@"UA-139398409-5"];
    [MPGoogleAnalyticsTracker activateConfiguration:configuration];
    [MPGoogleAnalyticsTracker trackScreen:@"MainView"];
}

- (void)loadChanelClient {
    // close current
    if (self.client) {
        [self.client close];
        self.client = nil;
    }
    
    // create a new
    if ([DesktopSetting sharedSetting].bluetoothSelected) {
        self.client = [ChannelClientFactory createClient:ChannelType_Bluetooth];
    } else {
        self.client = [ChannelClientFactory createClient:ChannelType_IPNetwork];
    }
    [self.client setDelegate:self];
    [self.client start];
}

- (void)loadSavedConnectionCode {
    NSString*lastConnCode = [DesktopSetting sharedSetting].connectionCode;
    if (lastConnCode.length > 0) {
        self.textFieldConnCode.stringValue = lastConnCode;
    }
}
- (void)checkAutoStartTask {
    if ([DesktopSetting sharedSetting].autoConnectWhenAppStartup) {
        NSString*lastConnCode = [DesktopSetting sharedSetting].connectionCode;
        if (lastConnCode.length > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self buttonConnectTapped:nil];
            });
        }
    }
}

- (void)reloadChannelLayout {
    if ([DesktopSetting sharedSetting].bluetoothSelected) {
        [self.tabViewChannel selectTabViewItemAtIndex:1];
    } else {
        [self.tabViewChannel selectTabViewItemAtIndex:0];
    }
}

- (void)reloadInputModeLayout {
    switch ([DesktopSetting sharedSetting].inputMode) {
        case InputModeStandard: {
            [self.tabViewInput selectTabViewItemAtIndex:0];
            break;
        }
        case InputModeMultiline: {
            [self.tabViewInput selectTabViewItemAtIndex:1];
            break;
        }
        case InputModeImmediate: {
            [self.tabViewInput selectTabViewItemAtIndex:2];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)showStatus:(NSString*)status {
    if (pthread_main_np()) {
        self.textFieldStatus.stringValue = status;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textFieldStatus.stringValue = status;
        });
    }
}

- (void)focusInputControlNow {
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            switch([DesktopSetting sharedSetting].inputMode) {
                case InputModeStandard: {
                    if (self.textFieldStandard.acceptsFirstResponder) {
                        [self.textFieldStandard becomeFirstResponder];
                    }
                    break;
                }
                case InputModeMultiline: {
                    if (self.textViewMultiline.acceptsFirstResponder) {
                        [self.textViewMultiline becomeFirstResponder];
                    }
                    break;
                }
                case InputModeImmediate: {
                    if (self.textFieldImmediate.acceptsFirstResponder) {
                        [self.textFieldImmediate becomeFirstResponder];
                    }
                    break;
                }
                default: {
                    break;
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"becomeFirstResponder exception : %@",exception);
        } @finally {
                
        }
    });
}


/*
 静态状态
 3 State: Init / Connecting / Ready
 when Init
    - button.title = "Connect"
    - button.enable = YES
 when Connecting
    - button.enable=NO
 when Ready
     - button.title = "Disconnect"
     - button.enable=YES
 */
- (void)onConnectChannelStaticStatusInit {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isButtonConnect = YES;
        self.buttonConnect.title = ttt(@"Connect");
        self.buttonConnect.enabled = YES;
        
        self.isConnectionReadyNow = NO;
        
        if ([DesktopSetting sharedSetting].autoReconnectWhenDisconnected) {
            if (self.onceConnectSucceed) {
                // 曾经连接成功过，且启用了自动重连
                [self buttonConnectTapped:nil];
            }
        }
        
        [self stopHeartBeatTimer];
    });
}

- (void)onConnectChannelStaticStatusConnecting {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isButtonConnect = YES;
        self.buttonConnect.title = ttt(@"Connect");
        self.buttonConnect.enabled = NO;
        
        self.isConnectionReadyNow = NO;
    });

}

- (void)onConnectChannelStaticStatusReady {
    // 标记连接成功过了
    self.onceConnectSucceed = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isButtonConnect = NO;
        self.buttonConnect.title = ttt(@"Disconnect");
        self.buttonConnect.enabled = YES;
        
        self.isConnectionReadyNow = YES;
        
        [self startHeartBeatTimer];
    });
}

- (void)onChannel:(ChannelType)channelType status:(ChannelClientStatus)statusType content:(NSString *)content data:(NSDictionary *)data {
    NSLog(@"channel = %@, type = %@, content = %@, data=%@", @(channelType), @(statusType), content, data);
    
    switch (channelType) {
        case ChannelType_IPNetwork: {
            switch(statusType) {
                case ChannelClientStatus_ConnectStart: {
                    [self showStatus:@"Connecting."];
                    [self onConnectChannelStaticStatusConnecting];
                    break;
                }
                case ChannelClientStatus_ConnectStartConnected: {
                    [self showStatus:@"Connecting.."];
                    [self onConnectChannelStaticStatusConnecting];
                    break;
                }
                case ChannelClientStatus_ConnectStartShakeHands: {
                    [self showStatus:@"Connecting..."];
                    [self onConnectChannelStaticStatusConnecting];
                    break;
                }
                case ChannelClientStatus_ConnectReady: {
                    [self showStatus:ttt(@"Connected, Enjoy Typing :)")];
                    [self focusInputControlNow];
                    [self onConnectChannelStaticStatusReady];
                    break;
                }
                case ChannelClientStatus_ConnectFailed: {
                    [self showStatus:@"Connect Failed"];
                    [self onConnectChannelStaticStatusInit];
                    break;
                }
                case ChannelClientStatus_ConnectClose: {
                    [self showStatus:@"Connection Closed"];
                    [self onConnectChannelStaticStatusInit];
                    break;
                }
            }
            break;
        }
        case ChannelType_Bluetooth: {
            switch(statusType) {
                case ChannelClientStatus_ConnectStart: {
                    [self showStatus:@"Connecting"];
                    [self onConnectChannelStaticStatusConnecting];
                    break;
                }
                case ChannelClientStatus_ConnectStartConnected: {
                    [self showStatus:@"Connecting.."];
                    [self onConnectChannelStaticStatusConnecting];
                    break;
                }
                case ChannelClientStatus_ConnectStartShakeHands: {
                    [self showStatus:@"Connecting..."];
                    [self onConnectChannelStaticStatusConnecting];
                    break;
                }
                case ChannelClientStatus_ConnectReady: {
                    [self showStatus:ttt(@"Connected, Enjoy Typing :)")];
                    [self focusInputControlNow];
                    [self onConnectChannelStaticStatusReady];
                    break;
                }
                case ChannelClientStatus_ConnectFailed: {
                    [self showStatus:@"Connect Failed"];
                    [self onConnectChannelStaticStatusInit];
                    break;
                }
                case ChannelClientStatus_ConnectClose: {
                    [self showStatus:@"Connection Closed"];
                    [self onConnectChannelStaticStatusInit];
                    break;
                }
                case ChannelClientStatus_Unsupported: {
                    [self showStatus:@"Bluetooth Unsupported"];
                    [self onConnectChannelStaticStatusInit];
                    break;
                }
                case ChannelClientStatus_PowerOff: {
                    [self showStatus:@"Bluetooth Powered off"];
                    [self onConnectChannelStaticStatusInit];
                    break;
                }
                case ChannelClientStatus_Scanning: {
                    [self showStatus:@"Scanning..."];
                    [self onConnectChannelStaticStatusInit];
                    break;
                }
                case ChannelClientStatus_ServerList: {
                    // Bluetooth special
                    NSArray<NSString*> *names = [data objectForKey:@"names"];
                    [self updateBluetoothList:names];
                    break;
                }
            }
            break;
        }
        default: {
            break;
        }
    }
    
}

- (void)onChannel:(ChannelType)channelType command:(NSString *)command content:(NSString *)content data:(NSDictionary *)data {
    if ([command isEqualToString:@"pong"]) {
        [self updatePongTimestamp];
    }
}

- (void)updateBluetoothList:(NSArray<NSString*>*)names {
    if (names == nil) {
        return;
    }
    
    [self.popupButtonBluetoothList removeAllItems];
    [self.popupButtonBluetoothList addItemsWithTitles:names];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)buttonSendTapped:(id)sender {
    NSString *text = self.textViewMultiline.string;
    if (text.length == 0) {
        return;
    }
    
    if (!self.isConnectionReadyNow) {
        return;
    }
    
    NSUInteger kPartLength = 128;
    NSUInteger times = text.length / kPartLength;
    NSUInteger timesTail = text.length % kPartLength;

    if (times == 0 ) {
        [self channelSend:@"input" content:text];
    } else {
        NSMutableArray<NSString*> *parts = [[NSMutableArray alloc] init];
        NSUInteger loopCount = times + (timesTail>0?1:0);
        for (NSUInteger index = 0; index < loopCount; ++index) {
            NSUInteger thisLength = kPartLength;
            if (index == loopCount-1) {
                thisLength = timesTail;
            }
            NSString *part = [text substringWithRange:NSMakeRange(index * kPartLength, thisLength)];
            [parts addObject:part];
        }
        
        for (NSString *part in parts) {
            [self channelSend:@"input" content:part];
        }
    }
    
    self.textViewMultiline.string = @"";
}

- (void)channelSend:(NSString*)type content:(NSString*)content {
    if (!self.client) {
        return;
    }
    NSLog(@"send : %@", type);
    [self.client send:type content:content];
}

- (IBAction)buttonConnectTapped:(id)sender {
    if (self.isButtonConnect) {
        if ([DesktopSetting sharedSetting].bluetoothSelected) {
            [self connectByBluetooth];
        } else {
            [self connectByIPNetwork];
        }
    } else {
        if (self.client) {
            [self.client close];
        }
    }
}

- (void)connectByIPNetwork {
    NSString *code = self.textFieldConnCode.stringValue;
    code = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (code.length == 0) {
        return;
    }

    NSString *ipAddress = nil;
    // check if it is ip address
    if ([code containsString:@"."]) {
        NSArray *parts = [code componentsSeparatedByString:@"."];
        if (parts.count != 4) {
            // not a correct ip
            NSLog(@"invalid ip");
            [self showMessage:@"IP Incorrect"];
            return;
        }
        // valid code
        [[DesktopSetting sharedSetting] setConnectionCode:code];
        
        ipAddress = code;
    } else {
        // conn code , convert to ip address
        ipAddress = [Utils connectionCode2IpAddress:code];
        if (ipAddress.length == 0) {
            NSLog(@"invalid code");
            [self showMessage:@"Code incorrect"];
            return;
        }
        // valid ip address
        [[DesktopSetting sharedSetting] setConnectionCode:code];
    }
    
    NSLog(@"%@",ipAddress);

    [self showStatus:@"Connecting"];
    
    if (self.client) {
        [self.client connect:ipAddress];
    }
}

- (void)connectByBluetooth {
    NSString *name = self.popupButtonBluetoothList.titleOfSelectedItem;
    if (name.length == 0) {
        return;
    }
    
    if (self.client) {
        [self.client connect:name];
    }
}

- (void)showMessage:(NSString*)msg {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Okay"];
    [alert setMessageText:@"Tip"];
    [alert setInformativeText:msg];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
    }];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self checkFirstRun];
    
    [self.buttonConnect becomeFirstResponder];
}

- (void)checkFirstRun {
    BOOL hasRun = [[NSUserDefaults standardUserDefaults] boolForKey:@"runFlag"];
    if (!hasRun) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"runFlag"];
        
        [self showMessage:ttt(@"first.start.guide")];
    }
}

- (void)inputHandler:(InputHandler *)handler command:(NSString *)command content:(NSString *)content {
    [self channelSend:command content:content];
}

- (void)startHeartBeatTimer {
    if (self.heartBeatTimer) {
        return;
    }
    self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(heartBeatTimerTicked) userInfo:nil repeats:YES];
}

- (void)stopHeartBeatTimer {
    if (!self.heartBeatTimer) {
        return;
    }
    [self.heartBeatTimer invalidate];
    self.heartBeatTimer = nil;
    self.pongTimestamp = 0;
}

- (void)heartBeatTimerTicked {
    [self channelSend:@"ping" content:@""];
    
    [self checkPongTimestamp];
}

- (void)updatePongTimestamp {
    self.pongTimestamp = CACurrentMediaTime();
}

- (void)checkPongTimestamp {
    if (self.pongTimestamp == 0) {
        return;
    }
    
    // Not check bluetooth now
    if ([DesktopSetting sharedSetting].bluetoothSelected) {
        return;
    }
    
    if (CACurrentMediaTime() - self.pongTimestamp > 10) {
        NSLog(@"Connection may lost");
        if (self.client) {
            [self.client close];
        }
    }
}

@end
