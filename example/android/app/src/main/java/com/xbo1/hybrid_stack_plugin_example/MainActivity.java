package com.xbo1.hybrid_stack_plugin_example;

import android.os.Bundle;

import com.xbo1.hybrid_stack_plugin.HSRouter;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    HSRouter.sharedInstance().setAppContext(this);
  }

  @Override
  protected void onResume() {
    super.onResume();
    HSRouter.sharedInstance().setAppContext(this);
  }
}
