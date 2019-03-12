#import <Flutter/Flutter.h>

typedef void(^HSPageResult)(NSDictionary * result);

@interface HybridStackPlugin : NSObject<FlutterPlugin>
+ (instancetype)sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;

+ (void)addRoute:(NSString *)pageId clazz:(Class)clazz;

+ (void)pushFlutterPage:(NSString *)pageId args:(NSDictionary *)args block:(HSPageResult)block;

//内部使用
- (void)showFlutterPage:(NSString *)pageId args:(NSDictionary *)args result:(FlutterResult)result;
@end
