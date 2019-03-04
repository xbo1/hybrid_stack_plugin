import 'package:flutter/material.dart';

class HSRouter {
  /// 初始化逻辑
  /// [key] 是获取 navigator state 用的
  static HSRouter init({@required GlobalKey<NavigatorState> key}) {
    _singleton = HSRouter._internal(key);
    return _singleton;
  }
  HSRouter._internal(GlobalKey<NavigatorState> key) {
    _navigatorStateKey = key;
  }
  static HSRouter get instance {
    if (_singleton == null) {
      throw Exception('must call Router.init(key) first');
    }
    return _singleton;
  }
  static HSRouter _singleton;
  /// flutter 页面的导航器 NavigatorState
  GlobalKey<NavigatorState> _navigatorStateKey;
}