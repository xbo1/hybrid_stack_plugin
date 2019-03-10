package com.xbo1.hybrid_stack_plugin_example;


import android.app.Application;

import com.xbo1.hybrid_stack_plugin.HybridStackPlugin;

import io.flutter.view.FlutterMain;


public class App extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        FlutterMain.startInitialization(this);
        HybridStackPlugin.getInstance().addRoute("demo", DemoActivity.class);
        HybridStackPlugin.getInstance().addRoute("demo2", Demo2Activity.class);

    }
}
