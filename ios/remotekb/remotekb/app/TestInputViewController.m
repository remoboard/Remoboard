//
//  TestInputViewController.m
//  remotekb
//
//  Created by everettjf on 2019/8/29.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "TestInputViewController.h"
#import "Masonry.h"
#import "PAAUI.h"

@interface TestInputViewController ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation TestInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ttt(@"vc.testinput.title");
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    self.textView = [[UITextView alloc] init];
    self.textView.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.textView.text = ttt(@"vc.testinput.defaulttext");
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.textView canBecomeFirstResponder]) {
        [self.textView becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
