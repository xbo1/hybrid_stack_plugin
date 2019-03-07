package com.xbo1.hybrid_stack_plugin_example;


import com.xbo1.hybrid_stack_plugin.HybridStackPlugin;

import io.flutter.app.FlutterApplication;


public class App extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        HybridStackPlugin.getInstance().addRoute("demo", DemoActivity.class);
        HybridStackPlugin.getInstance().addRoute("demo2", Demo2Activity.class);

    }
}
