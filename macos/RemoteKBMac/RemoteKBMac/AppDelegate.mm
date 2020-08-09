//
//  AppDelegate.m
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/16.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "AppDelegate.h"
#import "DesktopSetting.h"
#import "NSWindow+FullScreen.h"
#import "Utils.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSMenuItem *menuItemConnectByIP;
@property (weak) IBOutlet NSMenuItem *menuItemConnectByBluetooth;
@property (weak) IBOutlet NSMenuItem *menuItemInputModeStandard;
@property (weak) IBOutlet NSMenuItem *menuItemInputModeMultiline;
@property (weak) IBOutlet NSMenuItem *menuItemInputModeImmediate;
@property (weak) IBOutlet NSMenuItem *menuItemAutoReconnectWhenDisconnected;
@property (weak) IBOutlet NSMenuItem *menuItemAutoConnectWhenAppStartup;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self refreshConnectTypeMenuStatus];
    [self refreshInputModeMenuStatus];
    [self refreshAutoConnectMenuState];

    [self resetWindowSize];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)openUrl:(NSString*)url {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (void)showMessage:(NSString*)msg {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Okay"];
    [alert setMessageText:@"Tip"];
    [alert setInformativeText:msg];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    NSWindow *keyWindow = [NSApplication sharedApplication].keyWindow;
    [alert beginSheetModalForWindow:keyWindow completionHandler:^(NSModalResponse returnCode) {
    }];
    
}

- (IBAction)menuClickedHowToUse:(id)sender {
    [self openSite];
}
- (IBAction)menuClickedInstallPhoneApp:(id)sender {
    [self openSite];
}
- (IBAction)menuClickedMail:(id)sender {
    [self openSite];
}
- (IBAction)menuClickedWebsite:(id)sender {
    [self openSite];
}
- (IBAction)menuClickedWeibo:(id)sender {
    [self openUrl:@"https://www.weibo.com/everettjf"];
}
- (IBAction)menuClickedWechat:(id)sender {
    [self openUrl:@"https://everettjf.github.io/bukuzao/"];
}

- (void)openSite {
    ttt_zhcn;
    if (hasLang) {
        [self openUrl:@"https://remoboard.app/zhcn"];
    } else {
        [self openUrl:@"https://remoboard.app"];
    }
}

- (IBAction)menuClickedCheckUpdate:(id)sender {
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://remoboard.app/version/macos.txt"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!data) {
                [self showMessage:@"Failed to get latest version"];
                return;
            }
            NSString *latestVersion = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (latestVersion.length == 0) {
                [self showMessage:@"Failed to get latest version.."];
                return;
            }
            
            NSString *currentVersion = [self getAppVersion];
            if ([currentVersion isEqualToString:latestVersion]) {
                [self showMessage:@"Already latest version"];
            } else {
                [self showMessage:[NSString stringWithFormat:@"Current %@，Latest %@ :)", currentVersion, latestVersion]];
                [self openSite];
            }
        });
        
    }] resume];
}
- (NSString*)getAppVersion {
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@.%@",shortVersion,buildVersion];
    return appVersion;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

- (IBAction)menuClickedConnectByIP:(id)sender {
    [DesktopSetting sharedSetting].bluetoothSelected = NO;
    [self refreshConnectTypeMenuStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"channel-changed" object:nil];
}
- (IBAction)menuClickedConnectByBluetooth:(id)sender {
    [DesktopSetting sharedSetting].bluetoothSelected = YES;
    [self refreshConnectTypeMenuStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"channel-changed" object:nil];
}
- (IBAction)menuClickedInputModeStandard:(id)sender {
    [DesktopSetting sharedSetting].inputMode = InputModeStandard;
    [self refreshInputModeMenuStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"input-mode-changed" object:nil];
    [self resetWindowSize];
}
- (IBAction)menuClickedInputModeMultiline:(id)sender {
    [DesktopSetting sharedSetting].inputMode = InputModeMultiline;
    [self refreshInputModeMenuStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"input-mode-changed" object:nil];
    [self resetWindowSize];
}
- (IBAction)menuClickedInputModeImmediate:(id)sender {
    [DesktopSetting sharedSetting].inputMode = InputModeImmediate;
    [self refreshInputModeMenuStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"input-mode-changed" object:nil];
    [self resetWindowSize];
}
- (IBAction)menuClickedAutoReconnectWhenDisconnected:(id)sender {
    [DesktopSetting sharedSetting].autoReconnectWhenDisconnected = ![DesktopSetting sharedSetting].autoReconnectWhenDisconnected;
    [self refreshAutoConnectMenuState];
}
- (IBAction)menuClickedAutoConnectWhenAppStartup:(id)sender {
    [DesktopSetting sharedSetting].autoConnectWhenAppStartup = ![DesktopSetting sharedSetting].autoConnectWhenAppStartup;
    [self refreshAutoConnectMenuState];
}

- (void)refreshAutoConnectMenuState {
    if ([DesktopSetting sharedSetting].autoReconnectWhenDisconnected) {
        self.menuItemAutoReconnectWhenDisconnected.state = NSControlStateValueOn;
    } else {
        self.menuItemAutoReconnectWhenDisconnected.state = NSControlStateValueOff;
    }
    
    if ([DesktopSetting sharedSetting].autoConnectWhenAppStartup) {
        self.menuItemAutoConnectWhenAppStartup.state = NSControlStateValueOn;
    } else {
        self.menuItemAutoConnectWhenAppStartup.state = NSControlStateValueOff;
    }
}

- (void)refreshInputModeMenuStatus {
    switch([DesktopSetting sharedSetting].inputMode) {
        case InputModeStandard: {
            self.menuItemInputModeStandard.state = NSControlStateValueOn;
            self.menuItemInputModeMultiline.state = NSControlStateValueOff;
            self.menuItemInputModeImmediate.state = NSControlStateValueOff;
            break;
        }
        case InputModeMultiline: {
            self.menuItemInputModeStandard.state = NSControlStateValueOff;
            self.menuItemInputModeMultiline.state = NSControlStateValueOn;
            self.menuItemInputModeImmediate.state = NSControlStateValueOff;
            break;
        }
        case InputModeImmediate: {
            self.menuItemInputModeStandard.state = NSControlStateValueOff;
            self.menuItemInputModeMultiline.state = NSControlStateValueOff;
            self.menuItemInputModeImmediate.state = NSControlStateValueOn;
            break;
        }
        default: {
            break;
        }
    }
}

- (void)refreshConnectTypeMenuStatus {
    if ([DesktopSetting sharedSetting].bluetoothSelected) {
        self.menuItemConnectByBluetooth.state = NSControlStateValueOn;
        self.menuItemConnectByIP.state = NSControlStateValueOff;
    } else {
        self.menuItemConnectByIP.state = NSControlStateValueOn;
        self.menuItemConnectByBluetooth.state = NSControlStateValueOff;
    }
}

- (void)resetWindowSize {
    NSWindow *window = [NSApplication sharedApplication].keyWindow;
    if ([window rekb_isFullScreen]) {
        return;
    }
    
    NSRect frame = window.frame;
    NSLog(@"frame %@",@(frame));
    
    if ([DesktopSetting sharedSetting].inputMode == InputModeMultiline) {
        frame.size.height = 170;
    } else {
        frame.size.height = 105;
    }
    
    [window setFrame:frame display:YES];
}

@end
