//
//  HSFlutterViewController.h
//  hybrid_stack_plugin
//
//  Created by bob on 2019/3/9.
//

#import <Flutter/Flutter.h>
#import "HybridStackPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSFlutterViewController : UIViewController

- (instancetype)initWithFlutter:(FlutterViewController*)flutterViewController;

@property (nonatomic, strong) HSPageResult resultBlock;

@end

NS_ASSUME_NONNULL_END
