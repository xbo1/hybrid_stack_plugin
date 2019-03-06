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
    int result = await _channel.invokeMethod('pushNativePage', {
      'pageId':pageId,
      'args':args
    });
    return result;
  }
  popNativePage() {

  }

  void _setupChannelHandler() {
    _channel.setMethodCallHandler((MethodCall call) async {
      /// method name
      String methodName = call.method;
      switch (methodName) {
        case "pushFlutterPage": {
          Map args = call.arguments;
          HSRouter.instance.push(pageId: args['pageId']);
          break;
        }
        case "requestUpdateTheme": {
          // 请求更新主题色到 native 端，这里使用了一个测试接口，以后要注意
//          var preTheme = SystemChrome.latestStyle;
//          if (preTheme != null) {
//            SystemChannels.platform.invokeMethod("SystemChrome.setSystemUIOverlayStyle", _toMap(preTheme));
//          }
          break;
        }
        case "onBackPressed": {
          /// 这里重写了 onBackPressed 是防止出现黑屏无法返回退出的情况
//          return VDRouter.instance.onBackPressed();
        }
      }
    });
  }
}
