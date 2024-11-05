import 'package:flutter/services.dart';

class SocialFoundation{
  static final SocialFoundation instance = new SocialFoundation();
  static const MethodChannel _channel = const MethodChannel('social_foundation');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  static Future openMainActivity(){
    return _channel.invokeMethod('openMainActivity');
  }
  static Future<String?> getAndroidID() async {
    var result = await _channel.invokeMethod<String>('getAndroidID');
    return result?.isNotEmpty==true?result:null;
  }
  static Future<String?> getOAID() async {
    var result = await _channel.invokeMethod<String>('getOAID');
    return result?.isNotEmpty==true?result:null;
  }
}