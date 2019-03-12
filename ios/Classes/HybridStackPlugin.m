#import "HybridStackPlugin.h"
#import "HSRouter.h"

@interface HybridStackPlugin()
@property (nonatomic,strong) FlutterMethodChannel* methodChannel;
@end

@implementation HybridStackPlugin
+ (instancetype)sharedInstance{
    static HybridStackPlugin * sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [[HybridStackPlugin alloc] init];
    });
    return sharedInst;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  HybridStackPlugin* instance = [HybridStackPlugin sharedInstance];
  instance.methodChannel = [FlutterMethodChannel
      methodChannelWithName:@"hybrid_stack_plugin"
            binaryMessenger:[registrar messenger]];

  [registrar addMethodCallDelegate:instance channel:instance.methodChannel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"pushNativePage" isEqualToString:call.method]) {
      NSString *pageId = call.arguments[@"pageId"];
      [[HSRouter sharedInstance] openNativePage:pageId args:call.arguments result:result];
  }
  else if([@"popFlutterActivity" isEqualToString:call.method]) {
      [[HSRouter sharedInstance] finishFlutterViewController:call.arguments];
  }
  else if([@"startInitRoute" isEqualToString:call.method]) {
//      [self showFlutterPage:self.firstPageId args:self.firstArgs result:self.firstResult];
  }
  else if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (void)addRoute:(NSString *)pageId clazz:(Class)clazz {
    [[HSRouter sharedInstance] addRoute:pageId clazz:clazz];
}

+ (void)pushFlutterPage:(NSString *)pageId args:(NSDictionary *)args block:(HSPageResult)block{
    [[HSRouter sharedInstance] openFlutterPage:pageId args:args block:block];
}

//iOS中没有返回键，不用
- (void)popFlutterPage:(FlutterResult)result {
    if (self.methodChannel != nil) {
        [self.methodChannel invokeMethod:@"popFlutterPage" arguments:nil result:result];
    }
    else {
        result([FlutterError errorWithCode:@"-1" message:@"channel is null" details:nil]);
    }
}

//首次启动FlutterViewController后，路由到指定的页面
- (void)showFlutterPage:(NSString *)pageId args:(NSDictionary *)args result:(FlutterResult)result{
    if (self.methodChannel != nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:args forKey:@"args"];
        [dict setValue:pageId forKey:@"pageId"];
        [self.methodChannel invokeMethod:@"pushFlutterPage" arguments:dict result:result];
    }
}
@end
