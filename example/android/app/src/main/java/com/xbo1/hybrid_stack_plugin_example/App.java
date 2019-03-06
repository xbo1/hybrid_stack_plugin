package com.xbo1.hybrid_stack_plugin_example;

import android.app.Application;

import com.xbo1.hybrid_stack_plugin.HSRouter;

import io.flutter.app.FlutterApplication;


public class App extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        HSRouter.sharedInstance().addRoute("demo", DemoActivity.class);
        HSRouter.sharedInstance().addRoute("demo2", Demo2Activity.class);

    }
}
