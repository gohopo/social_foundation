import 'dart:async';

import 'package:fluwx/fluwx.dart';

class WechatHelper{
  static final _fluwx = Fluwx();
  static FluwxCancelable? subscription;
  static Future<bool> get isInstalled => _fluwx.isWeChatInstalled;
  static Future init(String appId,String universalLink) => _fluwx.registerApi(appId:appId,doOnIOS:true,universalLink:universalLink);
  static Future<WeChatAuthResponse> sendAuth() async {
    await _fluwx.authBy(which:NormalAuth(scope:'snsapi_userinfo',state:'wechat_sdk_demo_test'));
    var completer = Completer<WeChatAuthResponse>();
    subscription?.cancel();
    subscription = _fluwx.addSubscriber((resp){
      subscription?.cancel();
      completer.complete(resp as WeChatAuthResponse);
    });
    return completer.future;
  }
}