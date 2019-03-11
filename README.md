# hybrid_stack_plugin

A Flutter plugin for page manage between push&#x2F;pop native and flutter

- 此plugin主要参考自闲鱼发布的[hybrid_stack_manager](https://github.com/alibaba-flutter/hybrid_stack_manager)和voiddog的[hybrid_stack_manager](https://github.com/voiddog/hybrid_stack_manager)
- 闲鱼的hybrid_stack_manager提供了完整的思路和实现
- voiddog的hybrid_stack_manager中Android版本的优雅实现，提供了很大的帮助

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.io/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.


## 使用
在pubspec.yaml添加依赖

    hybrid_stack_plugin:0.0.1
在执行"flutter packages get"后，您可以查看包中的example，了解如何使用它。

### flutter
初始化
```
void main() {
  //初始化plugin，必须创建navKey，用于监听flutter页面路由跳转(push和pop)
  GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  HybridStackPlugin.init(key: navKey);
  //添加会被Native端调用的路由，id可以是任意字符串
  HybridStackPlugin.instance.addRoute('demo', (BuildContext context, Map args) {
    return MyApp(pageId: args['id'],);
  });
  HybridStackPlugin.instance.addRoute('demo2', (BuildContext context, Map args) {
    return Demo2(pageId: args['id'],);
  });
  // 必须添加navigatorKey，使得前面初始化的plugin可以监听路由跳转
  // 建议home是一个空白页
  runApp(MaterialApp(
    navigatorKey: navKey,
    home: EmptyPage(),
  ));
  // 必须告诉plugin启动成功，并跳转Native指定的页面
  HybridStackPlugin.instance.startInitRoute();
}
```
跳转到Native页面
```
onTap: () async {
  //跳到Native页面，pageId是在Native端注册好的路由，args是要传到Native端的参数
  var result = await HybridStackPlugin.instance.pushNativePage("demo", {'key':'hybrid_stack','age':9});
  //使用async/await可以得到Native页面返回时的结果
  print("main native result： $result");
},
```
Flutter内部的页面跳转，依旧使用Navigator.push/pop


### Android
初始化，在Application的onCreate中添加
```
  //初始化Flutter
  FlutterMain.startInitialization(this);
  //注册路由到plugin
  HybridStackPlugin.getInstance().addRoute("demo", DemoActivity.class);
  HybridStackPlugin.getInstance().addRoute("demo2", Demo2Activity.class);
```
跳转到Flutter页面
```
  HashMap<String, Object> args = new HashMap<>();
  args.put("id", pageId);
  HybridStackPlugin.getInstance().pushFlutterPage(DemoActivity.this, "demo", args);
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
初始化，在application初始化时，注册页面路由
```
  [[HybridStackPlugin sharedInstance] addRoute:@"demo" clazz:DemoViewController.class];
```
跳转到Flutter页面
```
  NSMutableDictionary* args = [NSMutableDictionary dictionary];
  [args setObject:@12 forKey:@"id"];
  [[HybridStackPlugin sharedInstance] pushFlutterPage:@"demo" args:args block:^(NSDictionary* dict) {
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
1. MaterialPageRoute中不要执行复杂操作
```
Navigator.push(context, MaterialPageRoute(builder: (context) {
  //pid = pid+1; 运算不能在这里，从Native返回时，iOS上会再执行(Android不会)
  return MyApp(pageId: pid,);
}));
```