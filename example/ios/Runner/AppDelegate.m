#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#include "DemoViewController.h"
#include <HybridStackPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
  // Override point for customization after application launch.
//  return [super application:application didFinishLaunchingWithOptions:launchOptions];
    DemoViewController *vc = [[DemoViewController alloc] init];
    UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:vc];
//    rootNav.interactivePopGestureRecognizer.delegate = self;
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.rootViewController = rootNav;
    [window makeKeyAndVisible];
    self.window = window;
    
    [HybridStackPlugin addRoute:@"demo" clazz:DemoViewController.class];
    [HybridStackPlugin addRoute:@"demo2" clazz:DemoViewController.class];
    return YES;
}

@end
