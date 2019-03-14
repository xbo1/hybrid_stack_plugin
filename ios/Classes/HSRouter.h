//
//  HSRouter.h
//  hybrid_stack_plugin
//
//  Created by bob on 2019/3/9.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "HSFlutterViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSRouter : NSObject
+ (instancetype)sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;

- (void)addRoute:(NSString *)pageId clazz:(Class)clazz;

//从Flutter打开新ViewController
- (void)openNativePage:(NSString *)pageId args:(NSDictionary *)args result:(FlutterResult)result;

//从本地ViewController打开Flutter页面
- (void)openFlutterPage:(NSString *)pageId args:(NSDictionary *)args block:(HSPageResult)block;

- (void)finishFlutterViewController:(NSDictionary *)args;

@end

NS_ASSUME_NONNULL_END
