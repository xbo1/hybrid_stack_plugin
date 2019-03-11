//
//  DemoViewController.m
//  Runner
//
//  Created by bob on 2019/3/10.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "DemoViewController.h"
#import "Demo2ViewController.h"
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
    
    if (_args != nil) {
        NSLog(@"传入参数:%@",[self convertToJsonData:_args]);
    }
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
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [btn setTitle:@"Click to Pop Native Page" forState:UIControlStateNormal];
    [view addSubview:btn];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setCenter:CGPointMake(view.center.x, view.center.y+150)];
    [btn addTarget:self action:@selector(onPopNative) forControlEvents:UIControlEventTouchUpInside];
    
    self.view = view;
}

- (void)onPopNative {
    if (_channelResult != nil) {
        NSMutableDictionary* args = [NSMutableDictionary dictionary];
        [args setObject:@"我是结果" forKey:@"result"];
        _channelResult(args);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onJumpNativePressed{
    Demo2ViewController *vc = [[Demo2ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onJumpFlutterPressed{
    NSMutableDictionary* args = [NSMutableDictionary dictionary];
    [args setObject:@12 forKey:@"id"];
    [[HybridStackPlugin sharedInstance] pushFlutterPage:@"demo" args:args block:^(NSDictionary* dict) {
        NSLog(@"返回结果:%@", [self convertToJsonData:dict]);
    }];
}

-(NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
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
