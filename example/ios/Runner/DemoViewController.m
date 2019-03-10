//
//  DemoViewController.m
//  Runner
//
//  Created by bob on 2019/3/10.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "DemoViewController.h"
#import <HybridStackPlugin.h>

static NSInteger sNativeVCIdx = 0;


@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sNativeVCIdx++;
    NSString *title = [NSString stringWithFormat:@"Native demo page(%ld)",(long)sNativeVCIdx];
    self.title = title;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)loadView{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [view setBackgroundColor:[UIColor whiteColor]];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [btn setTitle:@"Click to jump Native" forState:UIControlStateNormal];
    [view addSubview:btn];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setCenter:CGPointMake(view.center.x, view.center.y-50)];
    [btn addTarget:self action:@selector(onJumpNativePressed) forControlEvents:UIControlEventTouchUpInside];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [btn setTitle:@"Click to jump Flutter" forState:UIControlStateNormal];
    [view addSubview:btn];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setCenter:CGPointMake(view.center.x, view.center.y+50)];
    [btn addTarget:self action:@selector(onJumpFlutterPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.view = view;
}

- (void)onJumpNativePressed{
//    XOpenURLWithQueryAndParams(@"hrd://ndemo", nil, nil);
}

- (void)onJumpFlutterPressed{
//    XOpenURLWithQueryAndParams(@"hrd://fdemo", @{@"flutter":@(true)}, nil);
    NSMutableDictionary* args = [NSMutableDictionary dictionary];
    [args setObject:@12 forKey:@"id"];
    [[HybridStackPlugin sharedInstance] pushFlutterPage:@"demo" args:args block:nil];
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
