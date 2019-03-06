package com.xbo1.hybrid_stack_plugin_example;

import android.content.Context;
import android.util.AttributeSet;

import io.flutter.app.FlutterActivity;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterView;

public class MyFlutterActivity extends FlutterActivity {

    static FlutterNativeView flutterNativeView;
    @Override
    public FlutterNativeView createFlutterNativeView() {
        if (flutterNativeView == null) {
            flutterNativeView = new FlutterNativeView(this);
        }
        return flutterNativeView;
    }

    @Override
    public boolean retainFlutterNativeView() {
        return true;
    }

    @Override
    public FlutterView createFlutterView(Context context) {
        FlutterNativeView nativeView = createFlutterNativeView();
        return new FlutterView(context, (AttributeSet)null, nativeView);
    }
}
