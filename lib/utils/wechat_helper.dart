import 'dart:async';

import 'package:fluwx/fluwx.dart';

class WechatHelper{
  static StreamSubscription subscription;
  static Future init(String appId) => registerWxApi(appId:appId,doOnIOS:false);
  static Future<WeChatAuthResponse> sendAuth() async {
    await sendWeChatAuth(scope:'snsapi_userinfo',state:'wechat_sdk_demo_test');
    var completer = Completer<WeChatAuthResponse>();
    subscription?.cancel();
    subscription = weChatResponseEventHandler.listen((resp){
      subscription?.cancel();
      completer.complete(resp as WeChatAuthResponse);
    });
    return completer.future;
  }
}