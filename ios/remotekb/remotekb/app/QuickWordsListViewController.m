//
//  QuickWordsListViewController.m
//  remotekb
//
//  Created by everettjf on 2019/8/28.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "QuickWordsListViewController.h"
#import "KBSetting.h"
#import "EditQuickWordViewController.h"
#import "Masonry.h"
#import "PAAUI.h"

@interface QuickWordsListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString*> *items;
@end

@implementation QuickWordsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = ttt(@"vc.quickwordslist.title");
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(barButtonAddTapped:)];
    
    self.tableView = [[UITableView alloc] init];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self reloadItems];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"QuickWordsUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self reloadItems];
    }];
}

- (void)reloadItems {
    self.items = [[KBSetting sharedSetting] readWords];
    
    if (self.items.count == 0) {
        // initial some
        [[KBSetting sharedSetting] resetDefaultWords];        
        self.items = [[KBSetting sharedSetting] readWords];
    }
    
    [self.tableView reloadData];
}

- (void)barButtonAddTapped:(id)sender {
    EditQuickWordViewController *vc = [[EditQuickWordViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *text = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [self.items objectAtIndex:indexPath.row];

    EditQuickWordViewController *vc = [[EditQuickWordViewController alloc] initWithWord:text];
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
