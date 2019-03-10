//
//  HSRouter.m
//  hybrid_stack_plugin
//
//  Created by bob on 2019/3/9.
//

#import "HSRouter.h"
#import <objc/runtime.h>

@interface HSRouter()

@property (nonatomic, strong) NSMutableDictionary* routes;

//@property (nonatomic, strong) NSMutableArray* flutterViewControllers;

@property (nonatomic, strong) FlutterEngine* flutterEngine;
@end

@implementation HSRouter
+ (instancetype)sharedInstance{
    static HSRouter * sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [[HSRouter alloc] init];
        sharedInst.routes = [[NSMutableDictionary alloc] init];
//        sharedInst.flutterViewControllers = [[NSMutableArray alloc] init];
        [sharedInst initFlutter];
    });
    return sharedInst;
}

- (void) initFlutter {
    if (_flutterEngine != nil) {
        return;
    }
    _flutterEngine = [[FlutterEngine alloc] initWithName:@"default_engine" project:nil];
    [_flutterEngine runWithEntrypoint:nil];
    [NSClassFromString(@"GeneratedPluginRegistrant") performSelector:NSSelectorFromString(@"registerWithRegistry:") withObject:_flutterEngine];
}

- (void)addRoute:(NSString *)pageId clazz:(Class)clazz {
    [self.routes setValue:clazz forKey:pageId];
}

- (void)openFlutterPage:(NSString *)pageId args:(NSDictionary *)args block:(HSPageResult)block{
    //push Flutter ViewController
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:pageId forKey:@"pageId"];
    [dict setValue:args forKey:@"args"];
    HSFlutterViewController *vc = [[HSFlutterViewController alloc] initWithEngineAndArgs:_flutterEngine args:dict];
    UINavigationController *nav = (UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    if (block != nil) {
        vc.resultBlock = block;
    }
    [nav pushViewController:vc animated:YES];
}

- (void)openNativePage:(NSString *)pageId args:(NSDictionary *)args result:(FlutterResult)result {
    Class clazz = [[self routes] objectForKey:pageId];
    if (clazz == nil) {
        return;
    }
    //push native ViewController
    UINavigationController *nav = (UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    id vc = [[clazz alloc] init];
    if ([self hasArgsProperty:clazz]) {
        [vc setObject:args forKey:@"args"];
    }
    [nav pushViewController:vc animated:YES];
}
- (BOOL)hasArgsProperty:(Class)clazz {
    BOOL hasArgs = NO;
    unsigned int methodCount = 0;
    Ivar * ivars = class_copyIvarList([clazz class], &methodCount);
    for (unsigned int i = 0; i < methodCount; i ++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        const char * type = ivar_getTypeEncoding(ivar);
        if (strcmp(name, "args") == 0 && strcmp(type, "NSDictionary") == 0) {
            hasArgs = YES;
            break;
        }
    }
    free(ivars);
    return hasArgs;
}

- (void)finishFlutterViewController:(NSDictionary *)args {
    //NSLog(@"called finish flutter view controller by dart");
    UINavigationController *nav = (UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    if(nav.viewControllers.count>1 && [nav.topViewController isKindOfClass:[HSFlutterViewController class]]){
        HSFlutterViewController *vc = (HSFlutterViewController *)nav.topViewController;
        if (vc.resultBlock != nil) {
            vc.resultBlock(args);
        }
        [nav popViewControllerAnimated:YES];
    }
}

- (void)pushFlutterViewController:(HSFlutterViewController *)vc {
//    [self.flutterViewControllers addObject:vc];
}
- (void)popFlutterViewController {
//    [self.flutterViewControllers removeLastObject];
}
@end
