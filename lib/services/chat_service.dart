import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:social_foundation/utils/SfResponse.dart';

class ChatService {
  static ChatService _instance;
  static const MethodChannel _channel = const MethodChannel('social_foundation/chat');
  static const EventChannel _eventChannel = const EventChannel("social_foundation/chat/events");
  ChatEventHandler _eventHandler;
  static String _clientId;

  void _onInitialized(){
    _eventChannel.receiveBroadcastStream().listen((data){
      if(_eventHandler == null) return;
      String event = data['event'];
      var conversation = data['conversation']!=null ? ChatConversation.fromJsonString(data['conversation']) : null;
      var message = data['message']!=null ? ChatMessage.fromJsonString(data['message']) : null;
      switch(event){
        case 'onMessageReceived':
          _eventHandler.onMessageReceived(conversation,message);
          break;
        case 'onUnreadMessagesCountUpdated':
          _eventHandler.onUnreadMessagesCountUpdated(conversation,message);
          break;
        case 'onLastDeliveredAtUpdated':
          _eventHandler.onLastDeliveredAtUpdated(conversation,message);
          break;
        case 'onLastReadAtUpdated':
          _eventHandler.onLastReadAtUpdated(conversation,message);
          break;
        case 'onMessageUpdated':
          _eventHandler.onMessageUpdated(conversation,message);
          break;
        case 'onMessageRecalled':
          _eventHandler.onMessageRecalled(conversation,message);
          break;
      }
    });
  }
  void handleEvents(ChatEventHandler handler) {
    _eventHandler = handler;
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
      _channel.invokeMethod('initialize', {'appId': appId, 'appKey': appKey, 'serverURL': serverURL});
    }
    return ChatService.getInstance();
  }
  static Future<SfResponse> login(String userId) async {
    var result = await _channel.invokeMethod('login', {'userId': userId});
    var response = new SfResponse.fromJson(result);
    if(ChatCode.Success == response.code){
      _clientId = response.result;
    }
    return response;
  }
  static Future<SfResponse> close() async {
    var result = await _channel.invokeMethod('close');
    return new SfResponse.fromJson(result);
  }
  static Future<SfResponse> sendMessage(String conversationId,String message) async {
    var result = await _channel.invokeMethod('sendMessage',{'conversationId':conversationId,'message':message});
    return new SfResponse.fromJson(result);
  }
  static Future<SfResponse> setConversationRead(String conversationId) async {
    var result = await _channel.invokeMethod('setConversationRead');
    return new SfResponse.fromJson(result);
  }
}

class ChatCode {
  static const int Success = 0;
  static const int Error = 1;
}

class ChatMessageStatus {
  static const String None = "AVIMMessageStatusNone"; //未知
  static const String Sending = "AVIMMessageStatusSending"; //发送中
  static const String Sent = "AVIMMessageStatusSent"; //发送成功
  static const String Receipt = "AVIMMessageStatusReceipt"; //被接收
  static const String Failed = "AVIMMessageStatusFailed"; //失败
}

class ChatConversation {
  String convId;
  String name;
  String creator;
  int createdAt;
  int updatedAt;
  List<String> members;
  int unreadMessagesCount;
  ChatMessage lastMessage;
  int lastMessageAt;
  bool transient;
  ChatConversation(
    this.convId,this.name,this.creator,this.createdAt,this.updatedAt,this.members,
    this.unreadMessagesCount,this.lastMessage,this.lastMessageAt,this.transient
  );
  ChatConversation.fromJson(Map data) : this(
    data['conversationId'],data['name'],data['creator'],data['createdAt'],data['updatedAt'],data['members'].cast<String>(),
    data['unreadMessagesCount'],ChatMessage.fromJson(data['lastMessage']),data['lastMessageAt'],data['transient']
  );
  ChatConversation.fromJsonString(String data) : this.fromJson(jsonDecode(data));
}

class ChatMessage {
  String msgId;
  String convId;
  String fromId;
  int timestamp;
  String status;
  int receiptTimestamp;
  ChatMessage(this.msgId,this.convId,this.fromId,this.timestamp,this.status,this.receiptTimestamp);
  ChatMessage.fromJson(Map data) : this(data['messageId'],data['conversationId'],data['from'],data['timestamp'],data['messageStatus'],data['receiptTimestamp']);
  ChatMessage.fromJsonString(String data) : this.fromJson(jsonDecode(data));
}

class ChatEventHandler {
  void onMessageReceived(ChatConversation conversation,ChatMessage message){

  }
  void onUnreadMessagesCountUpdated(ChatConversation conversation,ChatMessage message){

  }
  void onLastDeliveredAtUpdated(ChatConversation conversation,ChatMessage message){

  }
  void onLastReadAtUpdated(ChatConversation conversation,ChatMessage message){

  }
  void onMessageUpdated(ChatConversation conversation,ChatMessage message){

  }
  void onMessageRecalled(ChatConversation conversation,ChatMessage message){

  }
}