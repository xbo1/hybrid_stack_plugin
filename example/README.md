# hybrid_stack_plugin_example

Demonstrates how to use the hybrid_stack_plugin plugin.

## 使用
在pubspec.yaml添加依赖

    hybrid_stack_plugin: ^0.0.3
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

Native使用参见：https://github.com/xbo1/hybrid_stack_plugin