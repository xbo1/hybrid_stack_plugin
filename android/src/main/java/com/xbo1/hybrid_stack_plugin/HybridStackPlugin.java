package com.xbo1.hybrid_stack_plugin;

import android.content.Intent;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** HybridStackPlugin */
public class HybridStackPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
//    channel = new MethodChannel(registrar.messenger(), "hybrid_stack_plugin");
//    channel.setMethodCallHandler(new  HybridStackPlugin());
    if (instance == null) {
      getInstance();
      // unregister instance
//      instance.channel.setMethodCallHandler(null);
//      instance = null;
    }
//    if (instance.channel == null) {
      instance.channel = new MethodChannel(registrar.messenger(), "hybrid_stack_plugin");
      instance.channel.setMethodCallHandler(instance);
//    }
//    instance = new HybridStackPlugin(registrar);
  }
  private HybridStackPlugin() {

  }
  private static HybridStackPlugin instance;
  public static synchronized HybridStackPlugin getInstance() {
    if (instance == null) {
//      throw new IllegalStateException("Must register plugin first");
      instance = new HybridStackPlugin();
    }
    return instance;
  }
  private MethodChannel channel;
  public void openFlutterPage(String pageId, HashMap<String, Object> args) {
    if (channel != null) {
      HashMap<String, Object> channelArgs = new HashMap<>();
      channelArgs.put("args", args);
//      channelArgs.put("pageName", pageName);
      channelArgs.put("pageId", pageId);
      channel.invokeMethod("pushFlutterPage", channelArgs, null);
    }
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;
    switch (method) {
      case "pushNativePage":
        String pageId = call.argument("pageId");
        HashMap<String, Object> args = call.arguments();
        HSRouter.sharedInstance().openNativePage(pageId, args);
        result.success(0);
        break;
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      default:
        result.notImplemented();
    }
  }
}
