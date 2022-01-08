import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statistic/statistic.dart';

void main() {
  const MethodChannel channel = MethodChannel('statistic');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Statistic.platformVersion, '42');
  });
}
