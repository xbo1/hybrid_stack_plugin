import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hybrid_stack_plugin/router.dart';

class HybridStackPlugin {
  static HybridStackPlugin _singleton;
  static HybridStackPlugin get instance {
    if (_singleton == null) {
      _singleton = HybridStackPlugin._internal();
    }
    return _singleton;
  }

  HybridStackPlugin._internal() {
    this._channel = const MethodChannel('hybrid_stack_plugin');
    _setupChannelHandler();
  }

  MethodChannel _channel;

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  pushNativePage(String pageId, Map args) async {
    var result = await _channel.invokeMethod('pushNativePage', {
      'pageId':pageId,
      'args':args
    });
    return result;
  }
  popFlutterActivity(Map args) {
    _channel.invokeMethod("popFlutterActivity", args);
  }
  void startInitRoute() {
    _channel.invokeMethod("startInitRoute");
  }

  void _setupChannelHandler() {
    _channel.setMethodCallHandler((MethodCall call) async {
      /// method name
      String methodName = call.method;
      switch (methodName) {
        case "pushFlutterPage": {
          Map args = call.arguments;
          var ret = await HSRouter.instance.push(pageId: args['pageId'], args:args['args']);
          return ret;
        }
        case "requestUpdateTheme": {
          // 请求更新主题色到 native 端，这里使用了一个测试接口，以后要注意
//          var preTheme = SystemChrome.latestStyle;
//          if (preTheme != null) {
//            SystemChannels.platform.invokeMethod("SystemChrome.setSystemUIOverlayStyle", _toMap(preTheme));
//          }
          break;
        }
        case "popFlutterPage": {
          /// 重写 onBackPressed
          if (HSRouter.instance.canPop()) {
            HSRouter.instance.doPop();
            return true;
          }
          HSRouter.instance.doPop();
          return false; //能pop返回true,否则返回false
        }
      }
    });
  }

}
