import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hybrid_stack_plugin/hybrid_stack_plugin.dart';
import 'package:hybrid_stack_plugin_example/Demo2.dart';

void main() {
  GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  HybridStackPlugin.init(key: navKey);
  HybridStackPlugin.instance.addRoute('demo', (BuildContext context, Map args) {
    return MyApp(pageId: args['id'],);
  });
  HybridStackPlugin.instance.addRoute('demo2', (BuildContext context, Map args) {
    return Demo2(pageId: args['id'],);
  });
  runApp(MaterialApp(
    navigatorKey: navKey,
    home: EmptyPage(),
  ));
  HybridStackPlugin.instance.startInitRoute();
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
                  var result = await HybridStackPlugin.instance.pushNativePage("demo", {});
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
