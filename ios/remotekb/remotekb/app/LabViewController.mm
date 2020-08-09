//
//  LabViewController.m
//  remotekb
//
//  Created by everettjf on 2019/10/11.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "LabViewController.h"
#import "Masonry.h"
#import "SCLAlertView.h"
#import "KBSetting.h"
#import "PAAUI.h"

@interface LabViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *groups;
@end

@implementation LabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = ttt(@"title.lab");;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    label.text = @"1l0v3y0u3000";
    label.font = [UIFont systemFontOfSize:12];
    self.tableView.tableFooterView = label;
    
    
    
    __weak typeof(self) wself = self;
    self.groups = @[
                   @{
                       @"title":ttt(@"title.lab"),
                       @"items":@[
                                @{
                                   @"icon":@"lab",
                                   @"title":ttt(@"title.whatislab"),
                                   @"action": ^{
                                       NSLog(@"action");
                                       [wself openLabSite];
                                   }
                                   },
                                ]
                    },

                    @{
                        @"title":ttt(@"title.manage"),
                        @"items":@[
                               @{
                                   @"icon":@"connection",
                                   @"title":ttt(@"title.connectionmode"),
                                    @"actionWithCell": ^(UITableView *tableView,UITableViewCell *cell,NSIndexPath *indexPath){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [wself chooseConnectionMode:tableView cell:cell indexPath:indexPath];
                                        });
                                    }
                                },
                                @{
                                   @"icon":@"desktop",
                                   @"title":ttt(@"title.downloaddesktop"),
                                   @"action": ^{
                                       NSLog(@"action");
                                       [wself openLabSite];
                                   }
                                    },
                                ]
                    },
                   ];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *group = self.groups[section];
    NSArray *items = group[@"items"];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *group = self.groups[indexPath.section];
    NSArray *items = group[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:item[@"icon"]];
    cell.textLabel.text = item[@"title"];
    
    // fix image size
    CGSize itemSize = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // style
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *group = self.groups[section];
    return group[@"title"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *group = self.groups[indexPath.section];
    NSArray *items = group[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    void (^action)(void) = item[@"action"];
    if (action) {
        action();
    }
    
    void (^actionWithCell)(UITableView *,UITableViewCell*,NSIndexPath*) = item[@"actionWithCell"];
    if (actionWithCell) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            actionWithCell(tableView,cell,indexPath);
        }
    }
}

- (void)chooseConnectionMode:(UITableView *)tableView cell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    NSString *bluetoothTitle = ttt(@"common.bluetooth");
    NSString *ipTitle = ttt(@"common.ipconnectioncode");
    NSString *httpTitle = ttt(@"common.http");
    
    KBConnectMode connectionMode = [KBSetting sharedSetting].connectMode;
    if ( connectionMode == KBConnectMode_HTTP) {
        httpTitle = [NSString stringWithFormat:@"✅ %@",httpTitle];
    } else if ( connectionMode == KBConnectMode_BLE) {
        bluetoothTitle = [NSString stringWithFormat:@"✅ %@",bluetoothTitle];
    } else {
        ipTitle = [NSString stringWithFormat:@"✅ %@",ipTitle];
    }
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:ttt(@"common.chooseconnectionmode") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:httpTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [KBSetting sharedSetting].connectMode = KBConnectMode_HTTP;
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:ipTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [KBSetting sharedSetting].connectMode = KBConnectMode_IP;
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:bluetoothTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [KBSetting sharedSetting].connectMode = KBConnectMode_BLE;
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:ttt(@"common.cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [actionSheet addAction:action1];
    [actionSheet addAction:action3];
    [actionSheet addAction:action2];
    [actionSheet addAction:action4];

    UIPopoverPresentationController * popPresenter = [actionSheet popoverPresentationController];
    popPresenter.sourceView = cell.contentView;
    popPresenter.sourceRect = [tableView rectForRowAtIndexPath:indexPath];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)openLabSite {
    NSString *base;
    ttt_zhcn;
    if (hasLang) {
        base = @"https://remoboard.app/zhcn/lab";
    } else {
        base = @"https://remoboard.app/lab";
    }
    [self openUrl:base];
}

- (void)openUrl:(NSString*)url {
    NSURL *settingUrl = [NSURL URLWithString:url];
    [[UIApplication sharedApplication] openURL:settingUrl options:@{} completionHandler:^(BOOL success) {}];
}

@end
