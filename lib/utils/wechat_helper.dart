import 'dart:async';

import 'package:fluwx/fluwx.dart';

class WechatHelper{
  static final _fluwx = Fluwx();
  static Fluwx get instance => _fluwx;
  static Future<bool> get isInstalled => _fluwx.isWeChatInstalled;
  static Future init(String appId,String universalLink) => _fluwx.registerApi(appId:appId,doOnIOS:true,universalLink:universalLink);
  static void listenOnce<T extends WeChatResponse>(void Function(T response) executor){
    FluwxCancelable? listener;
    listener = _fluwx.addSubscriber((response){
      if(response is T){
        executor(response);
        Future.microtask(()=>listener?.cancel());
      }
    });
  }
  static Future<WeChatAuthResponse> sendAuth(){
    var completer = Completer<WeChatAuthResponse>();
    listenOnce<WeChatAuthResponse>((response)=>completer.complete(response));
    _fluwx.authBy(which:NormalAuth(scope:'snsapi_userinfo',state:'wechat_sdk_demo_test'));
    return completer.future;
  }
  static Future<WeChatPaymentResponse> pay(PayType which){
    var completer = Completer<WeChatPaymentResponse>();
    listenOnce<WeChatPaymentResponse>((response)=>completer.complete(response));
    _fluwx.pay(which:which);
    return completer.future;
  }
  static Future<WeChatShareResponse> share(WeChatShareModel what){
    var completer = Completer<WeChatShareResponse>();
    listenOnce<WeChatShareResponse>((response)=>completer.complete(response));
    _fluwx.share(what);
    return completer.future;
  }
}