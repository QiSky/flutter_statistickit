
import 'dart:async';

import 'package:flutter/services.dart';

class Statistic {
  static const MethodChannel _channel =
      const MethodChannel('statistic');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
