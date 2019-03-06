import 'package:flutter/material.dart';


typedef PageWidgetBuilder = Widget Function(BuildContext context, Map args);

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

  addRoute(String id, WidgetBuilder builder) {
    _routes[id] = builder;
  }

  Map<String, WidgetBuilder> _routes = Map();
  /// flutter 页面的导航器 NavigatorState
  GlobalKey<NavigatorState> _navigatorStateKey;

  Future<dynamic> push({String pageId}) async {
    /// open the route
    var builder = _routes[pageId];
    if (builder == null) {
      builder = (context)=>_RouteNotFoundPage();
    }
    var pageRoute = MaterialPageRoute(builder: builder);
    final navState = _navigatorStateKey?.currentState;
    navState.push(pageRoute);
  }
}

class _RouteNotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text("页面丢失"),
      ),
    );
  }
}