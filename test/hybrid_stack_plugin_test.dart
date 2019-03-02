import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hybrid_stack_plugin/hybrid_stack_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('hybrid_stack_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await HybridStackPlugin.platformVersion, '42');
  });
}
