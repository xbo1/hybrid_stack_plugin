import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hybrid_stack_plugin/hybrid_stack_plugin.dart';
import 'Demo2.dart';

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

class EmptyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}

class MyApp extends StatefulWidget {
  final int pageId;
  MyApp({this.pageId});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await HybridStackPlugin.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    //build每次刷新都会执行，而且push到新页面后，也会执行，不能在此做复杂操作，尽量都在initState中完成
    int pid = widget.pageId;
    print("main page: $pid");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('flutter page id=$pid'),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
            Map args = Map();
            args['age'] = 12;
            args['name'] = 'bob';
            Navigator.of(context).pop(args);
          },),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text('This is a Flutter Page, Running on: $_platformVersion'),
              ),
              ListTile(
                title: Text('Open Flutter Page'),
                onTap: () {
                  pid = pid+1;
                  print("onTap $pid");
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    //pid = pid+1; 运算不能在这里，从Native返回时，iOS上会再执行(Android不会)
                    return MyApp(pageId: pid,);
                  }));
                },
              ),
              ListTile(
                title: Text('Open Native Page'),
                onTap: () async {
                  //跳到Native页面，pageId是在Native端注册好的路由，args是要传到Native端的参数
                  var result = await HybridStackPlugin.pushNativePage("demo", {'key':'hybrid_stack','age':9});
                  //使用async/await可以得到Native页面返回时的结果
                  print("main native result： $result");
                },
              )
            ],
          )
        ),
      ),
    );
  }
}
