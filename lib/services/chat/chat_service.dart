import 'dart:async';

import 'package:flutter/services.dart';
import 'package:social_foundation/utils/SfResponse.dart';

class ChatService {
  static ChatService _instance;
  static const MethodChannel _channel = const MethodChannel('social_foundation/chat');
  static const EventChannel _messageChannel = const EventChannel('social_foundation/chat/messages');
  static const EventChannel _eventChannel = const EventChannel("social_foundation/chat/events");
  StreamController _messageCtrl;
  StreamController _eventCtrl;
  static String _clientId;

  void _onInitialized(){
    _messageCtrl = StreamController.broadcast();
    _eventCtrl = StreamController.broadcast();

    _messageChannel.receiveBroadcastStream().listen((data){
      String event = data['event'];
      var conversation = data['conversation'];
      var message = data['message'];
      _messageCtrl.add({'event':event,'conversation':conversation,'message':message});
    });
    _eventChannel.receiveBroadcastStream().listen((data){
      String event = data['event'];
      var conversation = data['conversation'];
      var message = data['message'];
      _eventCtrl.add({'event':event,'conversation':conversation,'message':message});
    });
  }
  Stream handleMessages() {
    return _messageCtrl.stream;
  }
  Stream handleEvents() {
    return _eventCtrl.stream;
  }
  static ChatService getInstance(){
    if(_instance == null){
      _instance = new ChatService();
      _instance._onInitialized();
    }
    return _instance;
  }
  static Future<String> getClientId() async {
    return _clientId;
  }
  static Future<ChatService> initialize(String appId, String appKey, String serverURL) async {
    if (_instance == null){
      _channel.invokeMethod(ChatMethod.Initialize, {'appId': appId, 'appKey': appKey, 'serverURL': serverURL});
    }
    return ChatService.getInstance();
  }
  static Future<SfResponse> login(String userId) async {
    var result = await _channel.invokeMethod(ChatMethod.Login, {'userId': userId});
    var response = new SfResponse.fromJson(result);
    if(ChatCode.Success == response.code){
      _clientId = response.result;
    }
    return response;
  }
  static Future<SfResponse> close() async {
    var result = await _channel.invokeMethod(ChatMethod.Close);
    return new SfResponse.fromJson(result);
  }
  static Future<SfResponse> sendMessage(String conversationId,String message) async {
    var result = await _channel.invokeMethod(ChatMethod.SendMessage,{'conversationId':conversationId,'message':message});
    return new SfResponse.fromJson(result);
  }
  static Future<SfResponse> setConversationRead(String conversationId) async {
    var result = await _channel.invokeMethod(ChatMethod.SetConversationRead);
    return new SfResponse.fromJson(result);
  }
}

class ChatMethod {
  static const String GetPlatformVersion = "getPlatformVersion";
  static const String Initialize = "initialize";
  static const String Login = "login";
  static const String Close = "close";
  static const String SendMessage = "sendMessage";
  static const String SetConversationRead = "setConversationRead";
}

class ChatEvent {
  static const String OnMessageReceived = "onMessageReceived";
  static const String OnUnreadMessagesCountUpdated = "onUnreadMessagesCountUpdated";
  static const String OnLastDeliveredAtUpdated = "onLastDeliveredAtUpdated";
  static const String OnLastReadAtUpdated = "onLastReadAtUpdated";
  static const String OnMessageUpdated = "onMessageUpdated";
  static const String OnMessageRecalled = "onMessageRecalled";
}

class ChatCode {
  static const int Success = 0;
  static const int Error = 1;
}

class ChatMessageStatus {
  static const String None = "None"; //未知
  static const String Sending = "Sending"; //发送中
  static const String Sent = "Sent"; //发送成功
  static const String Receipt = "Receipt"; //被接收
  static const String Failed = "Failed"; //失败
}