import 'dart:async';

import 'package:flutter/services.dart';

class HybridStackPlugin {
  static const MethodChannel _channel =
      const MethodChannel('hybrid_stack_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
