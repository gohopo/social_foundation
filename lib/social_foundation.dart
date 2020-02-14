import 'dart:async';

import 'package:flutter/services.dart';
export './services/chat/chat_service.dart';

class SocialFoundation {
  static final SocialFoundation instance = new SocialFoundation();
  static const MethodChannel _channel = const MethodChannel('social_foundation');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
