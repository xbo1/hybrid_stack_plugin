# hybrid_stack_plugin

A Flutter plugin for page manage between push&#x2F;pop native and flutter

- 此plugin主要参考自闲鱼发布的[hybrid_stack_manager](https://github.com/alibaba-flutter/hybrid_stack_manager)和voiddog的[hybrid_stack_manager](https://github.com/voiddog/hybrid_stack_manager)
- 闲鱼的hybrid_stack_manager提供了完整的思路和实现
- voiddog的hybrid_stack_manager中Android版本的优雅实现，提供了很大的帮助

## 使用
flutter版本要求: 1.2

在pubspec.yaml添加依赖

    hybrid_stack_plugin: ^0.0.4
在执行"flutter packages get"后，您可以查看包中的example，了解如何使用它。

### flutter
初始化
```
void main() {
  //初始化plugin，必须创建navKey，用于监听flutter页面路由跳转(push和pop)
  GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  HybridStackPlugin.init(key: navKey);
  //添加会被Native端调用的路由，id可以是任意字符串
  HybridStackPlugin.addRoute('demo', (BuildContext context, Map args) {
    return MyApp(pageId: args['id'],);
  });
  HybridStackPlugin.addRoute('demo2', (BuildContext context, Map args) {
    return Demo2(pageId: args['id'],);
  });
  // 必须添加navigatorKey，使得前面初始化的plugin可以监听路由跳转
  // 建议home是一个空白页
  runApp(MaterialApp(
    navigatorKey: navKey,
    home: EmptyPage(),
  ));
  // 必须告诉plugin启动成功，并跳转Native指定的页面
  HybridStackPlugin.startInitRoute();
}
```
跳转到Native页面
```
onTap: () async {
  //跳到Native页面，pageId是在Native端注册好的路由，args是要传到Native端的参数
  var result = await HybridStackPlugin.pushNativePage("demo", {'key':'hybrid_stack','age':9});
  //使用async/await可以得到Native页面返回时的结果
  print("main native result： $result");
},
```
Flutter内部的页面跳转，依旧使用Navigator.push/pop


### Android
集成配置参见下面的 关于混合开发/Android打包

初始化，在Application的onCreate中添加
```
  //初始化Flutter
  FlutterMain.startInitialization(this);
  //注册路由到plugin
  HybridStackPlugin.addRoute("demo", DemoActivity.class);
  HybridStackPlugin.addRoute("demo2", Demo2Activity.class);
```
跳转到Flutter页面
```
  HashMap<String, Object> args = new HashMap<>();
  args.put("id", pageId);
  HybridStackPlugin.pushFlutterPage(DemoActivity.this, "demo", args);
```
接收Flutter启动Native页面是传过来的参数，在onCreate中添加
```
  Intent data = getIntent();
  if (data != null) {
    Serializable initArgs = data.getSerializableExtra("args");
    if (initArgs instanceof HashMap) {
      HashMap<String, Object> args = (HashMap<String, Object>)initArgs;
      JSONObject json = new JSONObject(args);
      //包含了pageId和args为key的数据
      Toast.makeText(this, "初始化参数:"+json.toString(), Toast.LENGTH_LONG).show();
    }
  }
```
接收Flutter返回回来的参数，在onActivityResult添加
```
  if (requestCode == HybridStackPlugin.NATIVE_REQUEST) {
    Serializable dataArgs = data.getSerializableExtra(HybridStackPlugin.EXTRA_KEY);
    if (dataArgs instanceof HashMap) {
      HashMap<String, Object> args = (HashMap<String, Object>)dataArgs;
      JSONObject json = new JSONObject(args);
      Toast.makeText(this, json.toString(), Toast.LENGTH_LONG).show();
    }
}
```
给Flutter返回结果
```
@Override
public void onBackPressed() {
//super.onBackPressed();
  Intent intent = new Intent();
  HashMap<String, Object> result = new HashMap<>();
  result.put("key", "demo");
  result.put("age", 13);
  intent.putExtra("args", result);
  setResult(918, intent);
  finish();
}
```

### iOS
集成配置参见下面的 关于混合开发/iOS打包

初始化，在application初始化时，注册页面路由
```
  //必须至少调用一次addRoute，它会初始化FlutterEngine
  [HybridStackPlugin addRoute:@"demo" clazz:DemoViewController.class];
```
跳转到Flutter页面
```
  NSMutableDictionary* args = [NSMutableDictionary dictionary];
  [args setObject:@12 forKey:@"id"];
  [HybridStackPlugin pushFlutterPage:@"demo" args:args block:^(NSDictionary* dict) {
    NSLog(@"返回结果:%@", [self convertToJsonData:dict]);
  }];
```
(可选)接收Flutter传过来的参数
```
  //定义成员变量
  @property (nonatomic, strong) NSDictionary* args;
//在viewWillAppear就可以获得Flutter传过来的参数
```
(可选)给Flutter返回结果
```
  //定义成员变量
  @property (nonatomic, strong) FlutterResult channelResult;
```
```
  //在pop的前调用_channelResult
  if (_channelResult != nil) {
    NSMutableDictionary* args = [NSMutableDictionary dictionary];
    [args setObject:@"我是结果" forKey:@"result"];
    _channelResult(args);
  }
  [self.navigationController popViewControllerAnimated:YES];
```


## 已知问题
1. iOS真机调试时，从Native调用Flutter，只有第一次进入图片能正常显示，模拟器测试正常。不使用本plugin也有同样问题，待Flutter官方解决。
2. MaterialPageRoute中不要执行复杂操作
```
Navigator.push(context, MaterialPageRoute(builder: (context) {
  //pid = pid+1; 运算不能在这里，从Native返回时，iOS上会再执行(Android不会)
  return MyApp(pageId: pid,);
}));
```

## 关于混合开发
在现有工程的基础上引入Flutter做混合开发有两种方式：

1. 以现有工程作为主工程，引入flutter模块。
2. 新建flutter工程作为主工程，将现有Android和iOS代码分别替换到flutter工程中的Android和iOS目录下。

对于方式2，flutter官方支持的更好，相当于把原生项目加到flutter中，要做一些迁移的工作。
对于方式1，在引入flutter模块时，可采用源码依赖和包依赖两种方式。
1. 源码依赖，参考官网的[Add2App](https://github.com/flutter/flutter/wiki/Add-Flutter-to-existing-apps)
2. 包依赖，打包成Android下的aar和iOS下的framework。

这里只讨论方式1的包依赖。

包依赖的好处：对于原生开发者而言，只是多引入了一个第三方的包，没有任何flutter的环境依赖

缺点：原生和flutter的联调不方便，增加了包管理负担。


### Android打包
#### 打包aar
以flutter module为例，
```
flutter run //生成debug.aar，不去执行，调试时会自动生成
flutter build apk //生成release.aar
```
在执行以上后，会在.android/Flutter/build/outputs/aar目录下，生成flutter-debug.aar和flutter-release.aar包。

在Android Studio中复制External Libraries -> Flutter Plugins下各个依赖plugin的aar，如
- hybrid_stack_plugin #本plugin
- path_provider #flutter必要的plugin
- shared_preferences #flutter必要的plugin

在各个plugin的android/build/outputs/aar下，有各自的debug.aar和release.aar

#### 集成到原生项目
复制以上所有的aar到原生项目的libs目录下。

在app的build.gradle中引入依赖即可
```
    debugImplementation fileTree(includes: ['*-debug.aar'], dir: 'libs')
    releaseImplementation fileTree(includes: ['*-release.aar'], dir: 'libs')
```
### iOS打包
```
flutter build ios //生成App.framework和Flutter.framework
```
复制App.framework，Flutter.framework，GeneratedPluginRegistrant.h/m以及相关的plugin的源码添加到Native工程中。

各plugin的源码在Android Studio中External Libraries -> Flutter Plugins各个plugin的ios/Classes目录下

GeneratedPluginRegistrant.m引用的plugin目录根据需要调整

在项目设置的General页下，把App.framework和Flutter.framework加入到Embedded Binaries中

