//
//  DemoViewController.h
//  Runner
//
//  Created by bob on 2019/3/10.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoViewController : UIViewController

@property (nonatomic, strong) FlutterResult channelResult;
@property (nonatomic, strong) NSDictionary* args;
@end

NS_ASSUME_NONNULL_END
