//
//  KeyboardViewController.m
//  keyboard
//
//  Created by everettjf on 2019/6/16.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "KeyboardViewController.h"
#import "Masonry.h"
#include <pthread.h>
#include "NetworkServerManager.h"
#import "Util.h"
#import "KBSetting.h"
#import "ChannelServiceFactory.h"
#import <NSAttributedString-DDHTML/NSAttributedString+DDHTML.h>
#import "TinyKeyboardView.h"
#import "WordListView.h"
#import "PAAUI.h"

/*
 View Hierarchy
 + Page Container
    + Page 1 (Status)
        + Message
    + Page 2 (Keyboard)
    + Page 3 (Words)
        + TableView
        + Guide
 
 + Button Container
    + Button Switch
    + Button Keyboard
    + Button Words
    + Button Help
    + Button Return
  */

@interface KeyboardViewController () <ChannelServiceDelegate, TinyKeyboardViewDelegate, WordListViewDelegate>

// Button Container
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) NSMutableArray<UIButton*> *buttonItems;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *keyboardButton;
@property (nonatomic, strong) UIButton *wordsButton;
@property (nonatomic, strong) UIButton *returnButton;

// Page Container
@property (nonatomic, strong) UIView *pageContainer;
@property (nonatomic, strong) NSMutableArray<UIView*> *pageItems;
@property (nonatomic, assign) NSUInteger pageCurrent;
// + Page Message
@property (nonatomic, strong) UIView *pageMessage;
@property (nonatomic, strong) UILabel *textLabelMessage;
@property (nonatomic, strong) UIView *extendView;
@property (nonatomic, strong) UIButton *handoffButton;
@property (nonatomic, strong) UIButton *cpButton;

// + Page Words
@property (nonatomic, strong) UIView *pageWords;
@property (nonatomic, strong) WordListView *wordListView;

// + Page Keyboard
@property (nonatomic, strong) UIView *pageKeyboard;
@property (nonatomic, strong) TinyKeyboardView *keyboardView;

@property (nonatomic, strong) id<ChannelService> channelService;

@property (nonatomic, copy) NSString *contentForCopy;
@property (nonatomic, copy) NSString *contentForHandoff;

@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self configColors:NO];
    
    [self switchToPage:0];
}

- (void)showFullAccessGuide{
    [self showMessageMainText:NSLocalizedString(@"GuideAllowFullAccess", nil)];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (![self isFullAccessEnabled]) {
        [self showFullAccessGuide];
        return;
    }
    
    [self startChannelService];
}

- (BOOL)isFullAccessEnabled {
    if ([UIDevice currentDevice].systemVersion.integerValue == 10) {
        return [UIPasteboard generalPasteboard];
    }
    return [self hasFullAccess];
}

- (void)startChannelService {
    [self showExtendViewUnderMessage:NO];
    [self clearContentForCopyAndHandoff];

    if (self.channelService != nil) {
        [self.channelService close];
        self.channelService = nil;
    }
    
    KBConnectMode connectMode = [KBSetting sharedSetting].connectMode;
    if (connectMode == KBConnectMode_HTTP) {
        self.channelService = [ChannelServiceFactory createChannel:@"http"];
    } else if (connectMode == KBConnectMode_BLE) {
        self.channelService = [ChannelServiceFactory createChannel:@"bluetooth"];
    } else {
        self.channelService = [ChannelServiceFactory createChannel:@"ipnetwork"];
    }
    [self.channelService setDelegate:self];
    [self.channelService start];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void)setupUI{
    self.buttonItems = [[NSMutableArray alloc]init];
    self.pageItems = [[NSMutableArray alloc] init];
    
    // Page Container
    self.pageContainer = [[UIView alloc] init];
    [self.view addSubview:self.pageContainer];
    [self.pageContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_greaterThanOrEqualTo(80);
    }];
    
    // Button Container
    self.buttonContainer = [[UIView alloc] init];
    [self.view addSubview:self.buttonContainer];
    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.pageContainer.mas_bottom).offset(5);
        make.bottom.mas_equalTo(self.view).offset(-5);
        make.height.mas_equalTo(30);
    }];
    
    
    // Pages
    {
        
        self.pageMessage = [[UIView alloc] init];
        [self.pageContainer addSubview:self.pageMessage];
        [self.pageItems addObject:self.pageMessage];
        [self.pageMessage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pageContainer.mas_left);
            make.right.equalTo(self.pageContainer.mas_right);
            make.top.equalTo(self.pageContainer.mas_top);
            make.bottom.equalTo(self.pageContainer.mas_bottom);
        }];
        
        self.pageWords = [[UIView alloc] init];
        [self.pageContainer addSubview:self.pageWords];
        [self.pageItems addObject:self.pageWords];
        [self.pageWords mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pageContainer.mas_left);
            make.right.equalTo(self.pageContainer.mas_right);
            make.top.equalTo(self.pageContainer.mas_top);
            make.bottom.equalTo(self.pageContainer.mas_bottom);
        }];
        
        self.pageKeyboard = [[UIView alloc] init];
        [self.pageContainer addSubview:self.pageKeyboard];
        [self.pageItems addObject:self.pageKeyboard];
        [self.pageKeyboard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pageContainer.mas_left);
            make.right.equalTo(self.pageContainer.mas_right);
            make.top.equalTo(self.pageContainer.mas_top);
            make.bottom.equalTo(self.pageContainer.mas_bottom);
        }];
        
        // Page Message - views
        {
            self.textLabelMessage = [[UILabel alloc] init];
            self.textLabelMessage.numberOfLines = 4;
            self.textLabelMessage.lineBreakMode = NSLineBreakByCharWrapping;
            self.textLabelMessage.textAlignment = NSTextAlignmentCenter;
            self.textLabelMessage.font = [UIFont systemFontOfSize:16];
            [self.pageMessage addSubview:self.textLabelMessage];
            [self.textLabelMessage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.pageMessage.mas_left).offset(5);
                make.right.equalTo(self.pageMessage.mas_right).offset(-5);
                make.top.equalTo(self.pageMessage.mas_top).offset(5);
                make.bottom.equalTo(self.pageMessage.mas_bottom).offset(-5);
            }];
            
            self.extendView = [[UIView alloc] init];
            [self.pageMessage addSubview:self.extendView];
            [self.extendView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.pageMessage.mas_centerX);
                make.bottom.equalTo(self.pageMessage.mas_bottom);
                make.height.mas_equalTo(25);
                make.width.mas_equalTo(150);
            }];
            {
                // Buttons in extend view
                self.cpButton = [[UIButton alloc] init];
                [self configButtonStyle:self.cpButton];
                [self.cpButton setTitle:NSLocalizedString(@"Copy", nil) forState:UIControlStateNormal];
                [self.cpButton addTarget:self action:@selector(buttonCopyTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self.extendView addSubview:self.cpButton];
                [self.buttonItems addObject:self.cpButton];
                [self.cpButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.extendView.mas_left);
                    make.top.equalTo(self.extendView.mas_top);
                    make.bottom.equalTo(self.extendView.mas_bottom);
                }];
                
                self.handoffButton = [[UIButton alloc] init];
                [self configButtonStyle:self.handoffButton];
                [self.handoffButton setTitle:NSLocalizedString(@"Handoff", nil) forState:UIControlStateNormal];
                [self.handoffButton addTarget:self action:@selector(buttonHandoffTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self.extendView addSubview:self.handoffButton];
                [self.buttonItems addObject:self.handoffButton];
                [self.handoffButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.extendView.mas_right);
                    make.top.equalTo(self.extendView.mas_top);
                    make.bottom.equalTo(self.extendView.mas_bottom);
                    make.left.equalTo(self.cpButton.mas_right).offset(5);
                    make.width.equalTo(self.cpButton.mas_width);
                }];
                
            }
        }
        // Page Setting - views
        {
            self.wordListView = [[WordListView alloc] init];
            self.wordListView.delegate = self;
            [self.pageWords addSubview:self.wordListView];
            [self.wordListView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.pageWords);
            }];
            
        }
        // Page Keyboard - views
        {
            self.keyboardView = [[TinyKeyboardView alloc] init];
            [self.pageKeyboard addSubview:self.keyboardView];
            self.keyboardView.delegate = self;
            [self.keyboardView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.pageKeyboard.mas_left);
                make.right.equalTo(self.pageKeyboard.mas_right);
                make.top.equalTo(self.pageKeyboard.mas_top);
                make.bottom.equalTo(self.pageKeyboard.mas_bottom);
            }];
        }
    }
    
    // Buttons
    {
        
        self.nextButton = [[UIButton alloc]init];
        [self.buttonItems addObject:self.nextButton];
        [self.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
        [self.nextButton addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
        [self configButtonStyle:self.nextButton];
        [self.buttonContainer addSubview:self.nextButton];
        
        self.keyboardButton = [[UIButton alloc]init];
        [self.buttonItems addObject:self.keyboardButton];
        [self.keyboardButton setTitle:NSLocalizedString(@"Qwerty", nil) forState:UIControlStateNormal];
        [self.keyboardButton addTarget:self action:@selector(buttonKeyboardTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self configButtonStyle:self.keyboardButton];
        [self.buttonContainer addSubview:self.keyboardButton];
        
        self.wordsButton = [[UIButton alloc]init];
        [self.buttonItems addObject:self.wordsButton];
        [self.wordsButton setTitle:NSLocalizedString(@"Words", nil) forState:UIControlStateNormal];
        [self.wordsButton addTarget:self action:@selector(buttonWordsTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self configButtonStyle:self.wordsButton];
        [self.buttonContainer addSubview:self.wordsButton];
        
        self.returnButton = [[UIButton alloc]init];
        [self.buttonItems addObject:self.returnButton];
        [self.returnButton setTitle:NSLocalizedString(@"Return", nil) forState:UIControlStateNormal];
        [self.returnButton addTarget:self action:@selector(buttonReturnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self configButtonStyle:self.returnButton];
        [self.buttonContainer addSubview:self.returnButton];
   
        [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.buttonContainer).offset(5);
            make.top.mas_equalTo(self.buttonContainer);
            make.bottom.mas_equalTo(self.buttonContainer);
        }];
        
        [self.keyboardButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nextButton.mas_right).offset(5);
            make.top.mas_equalTo(self.buttonContainer);
            make.bottom.mas_equalTo(self.buttonContainer);
            make.width.mas_equalTo(self.nextButton);
        }];
        
        [self.wordsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.keyboardButton.mas_right).offset(5);
            make.top.mas_equalTo(self.buttonContainer);
            make.bottom.mas_equalTo(self.buttonContainer);
            make.width.mas_equalTo(self.nextButton);
        }];
        
        [self.returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.wordsButton.mas_right).offset(5);
            make.right.mas_equalTo(self.buttonContainer).offset(-5);
            make.top.mas_equalTo(self.buttonContainer);
            make.bottom.mas_equalTo(self.buttonContainer);
            make.width.mas_equalTo(self.nextButton);
        }];
    }
    
}

- (void)switchToPage:(NSUInteger)pageIndex {
    if(pageIndex >= self.pageItems.count) {
        return;
    }
    
    self.pageCurrent = pageIndex;
    for(NSUInteger idx = 0; idx < self.pageItems.count; ++idx) {
        if(pageIndex == idx) {
            self.pageItems[idx].hidden = NO;
        } else {
            self.pageItems[idx].hidden = YES;
        }
    }
}

- (void)configColors:(BOOL)darkMode{
    
    if (darkMode) {
        // dark
        for(UIButton *button in self.buttonItems){
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [button setTintColor:[UIColor whiteColor]];
            [button setBackgroundColor:[UIColor colorWithWhite:138/255.0 alpha:1.0]];
        }
        self.textLabelMessage.textColor = [UIColor whiteColor];
    } else {
        // light
        for(UIButton *button in self.buttonItems){
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [button setTintColor:[UIColor blackColor]];
            [button setBackgroundColor:[UIColor whiteColor]];
        }
        self.textLabelMessage.textColor = [UIColor blackColor];
    }
}

- (void)configButtonStyle:(UIButton*)button{
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5.0;
    button.layer.shadowOffset = CGSizeMake(0, 1);
    button.layer.shadowRadius = 0.0;
    button.layer.shadowOpacity = 0.35;
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        [self configColors:YES];
    } else {
        [self configColors:NO];
    }
    switch (self.textDocumentProxy.returnKeyType) {
        case UIReturnKeySend:{
            [self.returnButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
            break;
        }
        case UIReturnKeyDone:{
            [self.returnButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
            break;
        }
        case UIReturnKeySearch:{
            [self.returnButton setTitle:NSLocalizedString(@"Search", nil) forState:UIControlStateNormal];
            break;
        }
        default:{
            [self.returnButton setTitle:NSLocalizedString(@"Return", nil) forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)buttonKeyboardTapped:(id)sender {
    [Util impactOccurred];
    
    if (self.pageCurrent != 2) {
        [self switchToPage:2];
    } else {
        [self switchToPage:0];
    }
}

- (void)buttonWordsTapped:(id)sender{
    [Util impactOccurred];
    
    if (self.pageCurrent == 0) {
        
        [self.wordListView reloadData];
        
        [self switchToPage:1];
    } else {
        [self switchToPage:0];
    }
}

- (void)buttonReturnTapped:(id)sender{
    [Util impactOccurred];
    
    [self.textDocumentProxy insertText:@"\n"];
}

- (void)showMessageMainText:(NSString*)text {
    if(pthread_main_np()){
        self.textLabelMessage.text = text;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textLabelMessage.text = text;
        });
    }
}

- (void)showMessageMainTextAttributed:(NSAttributedString*)text {
    if(pthread_main_np()){
        self.textLabelMessage.attributedText = text;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textLabelMessage.attributedText = text;
        });
    }
}

- (void)onIPNetworkConnectionCode:(NSString*)code ip:(NSString*)ip {
    NSMutableAttributedString *all = [[NSMutableAttributedString alloc] init];
    {
        NSString *str = [NSString stringWithFormat:@"<font size=\"17\">%@:</font>",ttt(@"ipnetwork.message.code")];
        NSAttributedString *attributedString = [NSAttributedString attributedStringFromHTML:str];
        [all appendAttributedString:attributedString];
    }
    {
        NSString *str = [NSString stringWithFormat:@"<font size=\"30\">%@</font>\n",code];
        NSAttributedString *attributedString = [NSAttributedString attributedStringFromHTML:str];
        [all appendAttributedString:attributedString];
    }
    {
        NSString *str = [NSString stringWithFormat:@"<font size=\"17\">IP:%@\n%@...</font>",ip,ttt(@"ipnetwork.message.waiting")];
        NSAttributedString *attributedString = [NSAttributedString attributedStringFromHTML:str];
        [all appendAttributedString:attributedString];
    }
    [self showMessageMainTextAttributed:all];
}

- (void)onBluetoothServerName:(NSString*)name {
    NSMutableAttributedString *all = [[NSMutableAttributedString alloc] init];
    {
        NSString *str = [NSString stringWithFormat:@"<font size=\"30\">%@</font>\n",name];
        NSAttributedString *attributedString = [NSAttributedString attributedStringFromHTML:str];
        [all appendAttributedString:attributedString];
    }
    [self showMessageMainTextAttributed:all];
}

- (void)onMessage:(nonnull NSString *)type content:(nonnull NSString *)content {
    if ([type isEqualToString:@"input"]) {
        [self.textDocumentProxy insertText:content];
    } else if ([type isEqualToString:@"input-delete"]) {
        [self.textDocumentProxy deleteBackward];
    } else if ([type isEqualToString:@"move-left"]) {
        [self.textDocumentProxy adjustTextPositionByCharacterOffset:-1];
    } else if ([type isEqualToString:@"move-right"]) {
        [self.textDocumentProxy adjustTextPositionByCharacterOffset:1];
    } else if ([type isEqualToString:@"move-up"]) {
        [self.textDocumentProxy adjustTextPositionByCharacterOffset:-20];
    } else if ([type isEqualToString:@"move-down"]) {
        [self.textDocumentProxy adjustTextPositionByCharacterOffset:20];
    } else {
        NSLog(@"Unknow type");
    }
}

- (void)onStatus:(nonnull NSString *)identifier content:(nonnull NSString *)content {
    if([identifier isEqualToString:@"waiting"]) {
        [self showMessageMainText:ttt(content)];
    } else if ([identifier isEqualToString:@"disconnected"]) {
        [self showMessageMainText:content];
    } else if ([identifier isEqualToString:@"connected"]) {
        [self showMessageMainText:ttt(@"message.connected")];
    } else if ([identifier isEqualToString:@"message"]) {
        [self showMessageMainText:ttt(content)];
    } else if ([identifier isEqualToString:@"copy-content"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contentForCopy = content;
            [self showExtendViewUnderMessage:YES];
        });
    } else if ([identifier isEqualToString:@"handoff-content"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contentForHandoff = content;
            [self showExtendViewUnderMessage:YES];
        });
    } else {
        
    }
}

- (void)TinyKeyboardView:(TinyKeyboardView *)keyboardView characterTapped:(NSString *)character {
    [self.textDocumentProxy insertText:character];
}

- (void)TinyKeyboardView:(TinyKeyboardView *)keyboardView specialTapped:(nonnull NSString *)type {
    if ([type isEqualToString:@"bak"]) {
        [self.textDocumentProxy deleteBackward];
    }
}

- (void)wordListView:(WordListView *)view wordsTapped:(NSString *)words {
    [self.textDocumentProxy insertText:words];
}

- (void)buttonHandoffTapped:(id)sender {
    [Util impactOccurred];
    
    if (self.contentForHandoff.length > 0) {
        NSString *encodedString = [self.contentForHandoff stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *urlString = [NSString stringWithFormat:@"remoboard://params?handoff=%@", encodedString];
        [self openUrl:urlString];
    }
}

- (void)openUrl:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    UIResponder* responder = self;
    while ((responder = [responder nextResponder]) != nil){
        if([responder respondsToSelector:@selector(openURL:)] == YES){
            [responder performSelector:@selector(openURL:) withObject:url];
        }
    }
}

- (void)buttonCopyTapped:(id)sender {
    [Util impactOccurred];
    
    if (self.contentForCopy.length > 0) {
        [UIPasteboard generalPasteboard].string = self.contentForCopy;
    }
}

- (void)showExtendViewUnderMessage:(BOOL)show {
    self.extendView.hidden = !show;
}

- (void)clearContentForCopyAndHandoff {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentForCopy = @"";
        self.contentForHandoff = @"";
    });
}

@end
