import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hybrid_stack_plugin/hybrid_stack_plugin.dart';
import 'package:hybrid_stack_plugin/router.dart';
import 'package:hybrid_stack_plugin_example/Demo2.dart';

void main() => runApp(MyHome());

int pageId = 0;

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
    HSRouter.init(key: navKey);
    HSRouter.instance.addRoute('demo', (BuildContext context) {
      pageId++;
      return MyApp(pageId: pageId,);
    });
    HSRouter.instance.addRoute('demo2', (BuildContext context) {
      pageId++;
      return Demo2(pageId: pageId,);
    });
    return MaterialApp(
      navigatorKey: navKey,
      home: MyApp(pageId: pageId,),
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
    int pid = widget.pageId;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('flutter page id=$pid'),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    pageId++;
                    return MyApp(pageId: pageId,);
                  }));
                },
              ),
              ListTile(
                title: Text('Open Native Page'),
                onTap: () {
                  HybridStackPlugin.instance.pushNativePage("demo", {});
                },
              )
            ],
          )
        ),
      ),
    );
  }
}
