import 'package:flutter/material.dart';
import 'package:hybrid_stack_plugin/hybrid_stack_plugin.dart';


typedef HSWidgetBuilder = Widget Function(BuildContext context, Map args);

class HSRouter {
  /// 初始化逻辑
  /// [key] 是获取 navigator state 用的
  static HSRouter init({@required GlobalKey<NavigatorState> key}) {
    _singleton = HSRouter._internal(key);
    //初始化plugin
    HybridStackPlugin.instance;
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

  addRoute(String id, HSWidgetBuilder builder) {
    _routes[id] = builder;
  }

  startRoute() {
    HybridStackPlugin.instance.startInitRoute();
  }
  Map<String, HSWidgetBuilder> _routes = Map();
  /// flutter 页面的导航器 NavigatorState
  GlobalKey<NavigatorState> _navigatorStateKey;

  Future<dynamic> push({String pageId, Map args}) async {
    /// open the route
    print('push page: $pageId');
    registerPageObserver();
    var builder = _routes[pageId];
    if (builder == null) {
      builder = (context, args)=>_RouteNotFoundPage(pageId, _routes);
    }
    var pageRoute = MaterialPageRoute(builder: (context) {
      return builder(context, args);
    });
    final navState = _navigatorStateKey?.currentState;
    navState.push(pageRoute);
    _firstRoutes[pageRoute] = pageId;
  }


  bool canPop() {
    int len = _navigatorHistory.length;
    if (len >= 1) {
      var route = _navigatorHistory[len-1];
      if (_firstRoutes.containsKey(route)) {
        return false;
      }
      return true;
    }
    return false;
  }

  void doPop() {
    NavigatorState navState = _navigatorStateKey?.currentState;
    navState.pop();
  }

  Map<Route, String> _firstRoutes = Map();
  final List<Route<dynamic>> _navigatorHistory = <Route<dynamic>>[];

  _NavigationObserver _naviObserver;
  void registerPageObserver() {
    if (_navigatorStateKey == null) {
      return;
    }
    if (_naviObserver != null) {
      return;
    }
    _naviObserver = _NavigationObserver();

    var state = _navigatorStateKey?.currentState;
    state.widget.observers.add(_naviObserver);
  }

  void prePoped(Route route) {
    _navigatorHistory.remove(route);
    if (_firstRoutes.containsKey(route)) {
      _firstRoutes.remove(route);
      HybridStackPlugin.instance.popFlutterActivity();
    }
  }

}

class _NavigationObserver extends NavigatorObserver {

  @override
  void didPush(Route route, Route previousRoute) {
    HSRouter.instance._navigatorHistory.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route previousRoute) {
    HSRouter.instance.prePoped(route);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    HSRouter.instance._navigatorHistory.remove(route);
    super.didRemove(route, previousRoute);
  }
  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    int index = HSRouter.instance._navigatorHistory.indexOf(oldRoute);
    if (index >= 0) {
      HSRouter.instance._navigatorHistory.removeAt(index);
      HSRouter.instance._navigatorHistory.insert(index, newRoute);
    }
    super.didReplace(newRoute:newRoute, oldRoute:oldRoute);
  }
}


class _RouteNotFoundPage extends StatelessWidget {
  final Map<String, HSWidgetBuilder> routes;
  final String pageId;
  _RouteNotFoundPage(this.pageId, this.routes);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          children: <Widget>[
            Text("$pageId 页面丢失", style: TextStyle(color: Colors.black, fontSize: 24),),
            Text("当前可用页面有：", style: TextStyle(color: Colors.black, fontSize: 24),),
            Flexible(child:
              ListView.builder(
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  var route = routes.keys.toList()[index];
                  return Text(route, style: TextStyle(color: Colors.black, fontSize: 20));
                },
              )
            )
          ],
        )
      ),
    );
  }
}