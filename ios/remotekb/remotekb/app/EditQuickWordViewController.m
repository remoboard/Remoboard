//
//  EditQuickWordViewController.m
//  remotekb
//
//  Created by everettjf on 2019/8/29.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "EditQuickWordViewController.h"
#import "KBSetting.h"
#import "Masonry.h"
#import "PAAUI.h"

@interface EditQuickWordViewController ()
@property (nonatomic, strong) NSString* wordEdit;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *buttonSave;
@end

@implementation EditQuickWordViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithWord:(NSString*)word {
    self = [super init];
    if (self) {
        _wordEdit = word;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.wordEdit.length > 0) {
        self.title = ttt(@"vc.quickwordsedit.title.edit");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(barButtonTrashTapped:)];
    } else {
        self.title = ttt(@"vc.quickwordsedit.title.add");
    }
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    // self textview half screen
    self.textView = [[UITextView alloc] init];
    self.textView.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.bottom.equalTo(self.view.mas_centerY);
    }];
    
    // self confirm button
    self.buttonSave = [[UIButton alloc] init];
    [self.buttonSave setTitle:ttt(@"vc.quickwordsedit.save") forState:UIControlStateNormal];
    self.buttonSave.titleLabel.font = [UIFont systemFontOfSize:20];
    self.buttonSave.backgroundColor = [UIColor blueColor];
    self.buttonSave.titleLabel.textColor = [UIColor whiteColor];
    [self.buttonSave addTarget:self action:@selector(buttonSaveTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonSave];
    [self.buttonSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.textView.mas_bottom).offset(10);
        make.height.equalTo(@(50));
    }];
    
    // data
    if (self.wordEdit.length > 0) {
        self.textView.text = self.wordEdit;
    }
}

- (void)barButtonTrashTapped:(id)sender {
    [[KBSetting sharedSetting] removeWord:self.wordEdit];
    
    [self popWithRefresh];
}

- (void)buttonSaveTapped:(id)sender {
    NSString *curText = self.textView.text;
    if (curText.length == 0) {
        return;
    }
    if (self.wordEdit.length > 0) {
        // edit
        [[KBSetting sharedSetting] removeWord:self.wordEdit];
    }
    
    [[KBSetting sharedSetting] removeWord:curText];
    [[KBSetting sharedSetting] addWord:curText];
    
    [self popWithRefresh];
}

- (void)popWithRefresh {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QuickWordsUpdate" object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.textView canBecomeFirstResponder]) {
        [self.textView becomeFirstResponder];
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
