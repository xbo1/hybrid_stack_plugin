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
@property (nonatomic, strong) FlutterEngine* flutterEngine;
@property (nonatomic, strong) FlutterViewController* flutterViewController;
@end

@implementation HSRouter
+ (instancetype)sharedInstance{
    static HSRouter * sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [[HSRouter alloc] init];
        sharedInst.routes = [[NSMutableDictionary alloc] init];
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
//    [NSClassFromString(@"GeneratedPluginRegistrant") performSelector:NSSelectorFromString(@"registerWithRegistry:") withObject:_flutterEngine];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
    if (clazz && [clazz respondsToSelector:NSSelectorFromString(@"registerWithRegistry:")]) {
        [clazz performSelector:NSSelectorFromString(@"registerWithRegistry:")
                    withObject:_flutterEngine];
    }
#pragma clang diagnostic pop
    _flutterViewController = [[FlutterViewController alloc] initWithEngine:_flutterEngine nibName:nil bundle:nil];
}

- (void)addRoute:(NSString *)pageId clazz:(Class)clazz {
    [self.routes setValue:clazz forKey:pageId];
}

- (void)openFlutterPage:(NSString *)pageId args:(NSDictionary *)args block:(HSPageResult)block{
    //push Flutter ViewController
    [[HybridStackPlugin sharedInstance] showFlutterPage:pageId args:args result:nil];
    
    HSFlutterViewController *vc = [[HSFlutterViewController alloc] initWithFlutter:_flutterViewController];
    if (block != nil) {
        vc.resultBlock = block;
    }
    UIViewController *curVC = [self topViewController];
    if (curVC.navigationController != nil) {
        [curVC.navigationController pushViewController:vc animated:YES];
    }
    else {
        [curVC presentViewController:vc animated:YES completion:nil];
    }
}

- (void)finishFlutterViewController:(NSDictionary *)args {
    //NSLog(@"called finish flutter view controller by dart");
    UIViewController *curVC = [self topViewController];
    if([curVC isKindOfClass:[HSFlutterViewController class]]){
        HSFlutterViewController *vc = (HSFlutterViewController *)curVC;
        if (vc.resultBlock != nil) {
            vc.resultBlock(args);
        }
        if (curVC.navigationController != nil) {
            [curVC.navigationController popViewControllerAnimated:YES];
        }
        else {
            [curVC dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


- (void)openNativePage:(NSString *)pageId args:(NSDictionary *)args result:(FlutterResult)result {
    Class clazz = [[self routes] objectForKey:pageId];
    if (clazz == nil) {
        return;
    }
    //push native ViewController
    UIViewController *curVC = [self topViewController];
    
    id vc = [[clazz alloc] init];
    [self setArgsProperty:clazz obj:vc value:args];
    [self setChannelResultProperty:clazz obj:vc value:result];
//    [vc setObject:result forKey:@"_channelResult"];
    if (curVC.navigationController != nil) {
        [curVC.navigationController pushViewController:vc animated:YES];
    }
    else {
        [curVC presentViewController:vc animated:YES completion:nil];
    }
}

- (BOOL)setChannelResultProperty:(Class)clazz obj:(id)obj value:(id)value {
    BOOL hasArgs = NO;
    unsigned int methodCount = 0;
    Ivar * ivars = class_copyIvarList([clazz class], &methodCount);
    for (unsigned int i = 0; i < methodCount; i ++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
//        const char * type = ivar_getTypeEncoding(ivar);
        if (strcmp(name, "_channelResult") == 0) {
            hasArgs = YES;
            object_setIvar(obj, ivar, value);
            break;
        }
    }
    free(ivars);
    return hasArgs;
}

- (BOOL)setArgsProperty:(Class)clazz obj:(id)obj value:(id)value {
    BOOL hasArgs = NO;
    unsigned int methodCount = 0;
    Ivar * ivars = class_copyIvarList([clazz class], &methodCount);
    for (unsigned int i = 0; i < methodCount; i ++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        const char * type = ivar_getTypeEncoding(ivar);
        if (strcmp(name, "_args") == 0 && strcmp(type, "@\"NSDictionary\"") == 0) {
            hasArgs = YES;
            object_setIvar(obj, ivar, value);
            break;
        }
    }
    free(ivars);
    return hasArgs;
}

- (UIViewController *)topViewController {
    UIViewController *vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    vc = [self _topViewController:vc];
    while (vc.presentedViewController) {
        vc = [self _topViewController:vc.presentedViewController];
    }
    return vc;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    }
    return vc;
}
@end
