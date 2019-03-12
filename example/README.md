# hybrid_stack_plugin_example

Demonstrates how to use the hybrid_stack_plugin plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## 使用
在pubspec.yaml添加依赖

    hybrid_stack_plugin: ^0.0.2
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

Native使用参见：https://github.com/xbo1/hybrid_stack_plugin