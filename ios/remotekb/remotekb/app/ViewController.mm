//
//  ViewController.m
//  remotekb
//
//  Created by everettjf on 2019/6/16.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "SCLAlertView.h"
#import "KBSetting.h"
#import "PAAUI.h"
#import "QuickWordsListViewController.h"
#import "TestInputViewController.h"
#import "LabViewController.h"
#import "AppUtil.h"
#import "AppMemoryData.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *groups;

@property (strong, nonatomic) NSUserActivity *userActivity;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    NSString *systemTitle = ttt(@"app.longname");
    NSString *topBarTitle = systemTitle;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.navigationController setNavigationBarHidden:YES];

    self.title = systemTitle;
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width,100)];
    UILabel *titleLabel = [[UILabel alloc] init];
    [header addSubview:titleLabel];

    titleLabel.text = topBarTitle;
    titleLabel.font = [UIFont systemFontOfSize:38 weight:UIFontWeightBold];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(header.mas_left).offset(20);
        make.bottom.equalTo(header.mas_bottom).offset(-10);
        make.right.equalTo(header.mas_right);
    }];
    UIView *sep = [[UIView alloc] init];
    sep.backgroundColor = [UIColor lightGrayColor];
    [header addSubview:sep];
    [sep mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(header.mas_left);
        make.right.equalTo(header.mas_right);
        make.bottom.equalTo(header.mas_bottom);
        make.height.equalTo(@(0.5));
    }];
    
    
    self.tableView.tableHeaderView = header;
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    ttt_zhcn;
    
    __weak typeof(self) wself = self;
    self.groups = @[
                   @{
                       @"title":ttt(@"title.general"),
                       @"items":@[
                           @{
                               @"icon":@"book",
                               @"title":ttt(@"title.howtouse"),
                               @"action": ^{
                                   NSLog(@"action");
                                   [wself openSite];
                               }
                               },
                           @{
                               @"icon":@"setup",
                               @"title":ttt(@"title.installguide"),
                               @"action": ^{
                                   NSLog(@"action");
                                   [wself showInstall];
                               }
                               },
                           @{
                               @"icon":@"auth",
                               @"title":ttt(@"title.allowfullaccess"),
                               @"action": ^{
                                   NSLog(@"action");
                                   [wself showEnableFullAccess];
                               }
                               },
                           @{
                               @"icon":@"help",
                               @"title":ttt(@"title.faq"),
                               @"action": ^{
                                   NSLog(@"action");
                                   [wself openSite];
                               }
                               },
                           ]
                       },
                   @{
                       @"title":ttt(@"title.manage"),
                       @"items":@[
                               @{
                                   @"icon":@"words",
                                   @"title":ttt(@"title.quickwords"),
                                   @"action": ^{
                                       QuickWordsListViewController *vc = [[QuickWordsListViewController alloc] init];
                                       [wself.navigationController pushViewController:vc animated:YES];
                                   }
                                   },
                               @{
                                   @"icon":@"test",
                                   @"title":ttt(@"title.testinput"),
                                   @"action": ^{
                                       TestInputViewController *vc = [[TestInputViewController alloc] init];
                                       [wself.navigationController pushViewController:vc animated:YES];
                                   }
                                   },
                               ]
                       },
                   @{
                       @"title":ttt(@"title.feedback"),
                       @"items":@[
                               @{
                                   @"icon":@"mail",
                                   @"title":ttt(@"title.email"),
                                   @"action": ^{
                                       NSLog(@"action");
                                       [wself openUrl:@"mailto:everettjf@live.com?subject=Remoboard_iOS"];
                                   }
                                   },
                               @{
                                   @"icon":@"weibo",
                                   @"title":ttt(@"title.weibo"),
                                   @"action": ^{
                                       NSLog(@"action");
                                       NSString *url = @"https://weibo.com/everettjf";
                                       [wself openUrl:url];
                                   }
                                   },
                               @{
                                   @"icon":@"wechat",
                                   @"title":ttt(@"title.wechat"),
                                   @"action": ^{
                                       NSLog(@"action");
                                       [wself openUrl:@"https://everettjf.github.io/bukuzao/"];
                                   }
                                   },
                               @{
                                   @"icon": (hasLang ? @"qq" : @"telegram"),
                                   @"title": (hasLang ? ttt(@"title.qqgroup") : ttt(@"title.telegram")),
                                   @"action": ^{
                                       if (hasLang) {
                                           [wself openUrl:@"mqqapi://card/show_pslcard?src_type=internal&version=1&card_type=group&uin=486615112"];
                                       }else {
                                           [wself openUrl:@"https://t.me/remoboard"];
                                       }
                                   }
                                   },
                               ]
                       },
                   @{
                       @"title":ttt(@"title.more"),
                       @"items":@[
                               @{
                                   @"icon":@"star",
                                   @"title":ttt(@"title.starapp"),
                                   @"action": ^{
                                       NSLog(@"action");
                                       NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",@"1474458879"];
                                       [wself openUrl:url];
                                   }
                                   },
                               @{
                                   @"icon":@"share",
                                   @"title":ttt(@"title.shareapp"),
                                   @"action": ^{
                                       NSLog(@"action");
                                       NSString *str;
                                       ttt_zhcn;
                                       if (hasLang) {
                                           str = @"远程输入法 - 电脑打字，手机输入 https://itunes.apple.com/cn/app/id1474458879";
                                       } else {
                                           str = @"Remoboard - Type From Desktop https://apps.apple.com/us/app/id1474458879";
                                       }
                                       [wself openShare:str];
                                   }
                                   },
                               @{
                                   @"icon":@"products",
                                   @"title": ttt(@"title.products"),
                                   @"action": ^{
                                       [wself openUrl:@"https://everettjf.github.io/products/"];
                                   }
                                   },
                               @{
                                   @"icon":@"lab",
                                   @"title": ttt(@"title.lab"),
                                   @"action": ^{
                                       [self openLab];
                                   }
                                   },
                               @{
                                   @"icon":@"app",
                                   @"title": [NSString stringWithFormat:@"%@ %@",ttt(@"title.appversion"), [AppUtil getAppVersion]],
                                   @"action": ^{
                                       NSLog(@"action");
                                       [self onAppVersionTapped];
                                   }
                                   },
                               ]
                       },
                   ];


    [[NSNotificationCenter defaultCenter] addObserverForName:@"HandoffUrl" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSString *handoffUrl = note.object;
        if (handoffUrl.length > 0 ) {
            self.userActivity = [[NSUserActivity alloc] initWithActivityType:NSUserActivityTypeBrowsingWeb];
            self.userActivity.webpageURL = [NSURL URLWithString:handoffUrl];
            [self.userActivity becomeCurrent];
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showInfo:@"Tips" subTitle:ttt(@"message.handoffcompleted") closeButtonTitle:@"Okay" duration:5.0f]; // Error
        }
        
    }];
}

- (void)openSite {
    NSString *base;
    ttt_zhcn;
    if (hasLang) {
        base = @"https://remoboard.app/zhcn/";
    } else {
        base = @"https://remoboard.app/";
    }
    [self openUrl:base];
}

- (void)openUrl:(NSString*)url {
    NSURL *settingUrl = [NSURL URLWithString:url];
    [[UIApplication sharedApplication] openURL:settingUrl options:@{} completionHandler:^(BOOL success) {}];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    if ([AppMemoryData shared].isNewVersionFirstLaunch) {
        // new version check
        // nothing for current version
    }
}

- (void)showAlert:(NSString*)text {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showInfo:@"Tips" subTitle:text closeButtonTitle:@"Okay" duration:0.0f]; // Error
}

- (void)openShare:(NSString*)str {
    
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[str] applicationActivities:nil];
    UIPopoverPresentationController *popover = activity.popoverPresentationController;
    if (popover) {
        popover.sourceView = self.view;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    [self presentViewController:activity animated:YES completion:NULL];
}

- (void)showInstall {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:ttt(@"common.viewdetailguide") actionBlock:^{
        [self openSite];
    }];

    [alert showInfo:ttt(@"common.title.install") subTitle:ttt(@"common.title.install.shortguide") closeButtonTitle:ttt(@"common.ok") duration:0.0f];
}

- (void)showEnableFullAccess {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:ttt(@"common.gotosetting") actionBlock:^{
        [AppUtil openSetting];
    }];
    [alert showInfo:ttt(@"common.howtoallow") subTitle:ttt(@"common.howtoallow.shortguide") closeButtonTitle:ttt(@"common.later") duration:0.0f];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 0) {
        if (self.navigationController.isNavigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    } else {
        if (!self.navigationController.isNavigationBarHidden) {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        }
    }
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
- (void)onAppVersionTapped {
    
    static int tapCount = 0;
    ++tapCount;
    
#ifdef DEBUG
    const int kThreshold = 0;
#else
    const int kThreshold = 7;
#endif
    
    if (tapCount >= kThreshold) {
        [self openLab];
    }
}

- (void)openLab {
    LabViewController *vc = [[LabViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
