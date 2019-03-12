package com.xbo1.hybrid_stack_plugin;

import android.app.Activity;

import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** HybridStackPlugin */
public class HybridStackPlugin implements MethodCallHandler {
  //used for called by native
  public static final int NATIVE_REQUEST = 8758;
  public static final String EXTRA_KEY = "args";


  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    if (instance == null) {
      getInstance();
    }
    instance.channel = new MethodChannel(registrar.messenger(), "hybrid_stack_plugin");
    instance.channel.setMethodCallHandler(instance);
  }
  private HybridStackPlugin() {

  }
  private static HybridStackPlugin instance;
  public static synchronized HybridStackPlugin getInstance() {
    if (instance == null) {
      instance = new HybridStackPlugin();
    }
    return instance;
  }
  private MethodChannel channel;
  public void addRoute(String pageId, Class clazz) {
    HSRouter.sharedInstance().addRoute(pageId, clazz);
  }
  public void pushFlutterPage(Activity activity, String pageId, HashMap<String, Object> args) {
    HSRouter.sharedInstance().openFlutterPage(activity, pageId, args);
  }
  void popFlutterPage(Result result) {
    if (channel != null) {
      channel.invokeMethod("popFlutterPage", null, result);
    }
    else if (result != null){
      result.error("-1", "channel is null", null);
    }
  }

  //flutter 内部路由
  void showFlutterPage(String pageId, HashMap<String, Object> args, Result result) {
    if (channel == null) {
      return;
    }
    if (pageId==null || pageId.isEmpty()) {
      return;
    }
    initArgs = args;
    initPageId = pageId;
    initResult = result;
    HashMap<String, Object> channelArgs = new HashMap<>();
    channelArgs.put("args", args);
//      channelArgs.put("pageName", pageName);
    channelArgs.put("pageId", pageId);
    channel.invokeMethod("pushFlutterPage", channelArgs, result);
  }
  private HashMap<String, Object> initArgs = new HashMap<>();
  private String initPageId = "";
  private Result initResult = null;
  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;
    HashMap<String, Object> args = call.arguments();
    switch (method) {
      case "pushNativePage":
        String pageId = call.argument("pageId");
        HSRouter.sharedInstance().openNativePage(pageId, args, result);
        break;
      case "startInitRoute":
        showFlutterPage(initPageId, initArgs, initResult);
        break;
      case "popFlutterActivity":
        HSRouter.sharedInstance().finishFlutterActivity(args);
        result.success(true);
        break;
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      default:
        result.notImplemented();
    }
  }
}
