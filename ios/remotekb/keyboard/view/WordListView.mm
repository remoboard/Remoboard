//
//  WordListView.m
//  keyboard
//
//  Created by everettjf on 2019/8/29.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "WordListView.h"
#import "KBSetting.h"
#import "Masonry.h"

@interface WordListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString*> *items;

@end

@implementation WordListView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        _items = @[];
        
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:separator];
        [separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top);
            make.height.equalTo(@(0.5));
        }];
        
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
        [self addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.top.equalTo(separator.mas_bottom);
            make.bottom.equalTo(self.mas_bottom);
        }];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *item = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = item;
    return cell;
}

- (void)reloadData {
    self.items = [[KBSetting sharedSetting] readWords];
    if (self.items.count == 0) {
        [[KBSetting sharedSetting] resetDefaultWords];
        self.items = [[KBSetting sharedSetting] readWords];
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = [self.items objectAtIndex:indexPath.row];
    if (item.length > 0) {
        if (self.delegate) {
            [self.delegate wordListView:self wordsTapped:item];
        }
    }
}

@end
