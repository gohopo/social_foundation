import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class ChatEventManager<TConversation,TMessage> {
  final MethodChannel _channel = MethodChannel('social_foundation/chat');
  final EventChannel _eventChannel = EventChannel("social_foundation/chat/events");
  ChatEventManager(String appId, String appKey, String serverURL){
    _channel.invokeMethod('initialize', {'appId': appId, 'appKey': appKey, 'serverURL': serverURL});
    _eventChannel.receiveBroadcastStream().listen(_handleEvent);
  }
  @protected _handleEvent(data){
    String event = data['event'];
    var conversation = convertConversation(data['conversation']);
    var message = convertMessage(data['message']);
    switch(event){
        case 'onMessageReceived':
          onMessageReceived(conversation,message);
          break;
        case 'onUnreadMessagesCountUpdated':
          onUnreadMessagesCountUpdated(conversation,message);
          break;
        case 'onLastDeliveredAtUpdated':
          onLastDeliveredAtUpdated(conversation,message);
          break;
        case 'onLastReadAtUpdated':
          onLastReadAtUpdated(conversation,message);
          break;
        case 'onMessageUpdated':
          onMessageUpdated(conversation,message);
          break;
        case 'onMessageRecalled':
          onMessageRecalled(conversation,message);
          break;
      }
  }
  Future<String> login(String userId) {
    return _channel.invokeMethod('login', {'userId': userId});
  }
  Future<String> close() {
    return _channel.invokeMethod('close');
  }
  Future<TMessage> sendMessage(String conversationId,String message) async {
    var result = await _channel.invokeMethod('sendMessage',{'conversationId':conversationId,'message':message});
    return convertMessage(result);
  }
  void setConversationRead(String conversationId) {
    _channel.invokeMethod('setConversationRead');
  }
  TConversation convertConversation(String conversation);
  TMessage convertMessage(String message);
  void onMessageReceived(TConversation conversation,TMessage message);
  void onUnreadMessagesCountUpdated(TConversation conversation,TMessage message);
  void onLastDeliveredAtUpdated(TConversation conversation,TMessage message);
  void onLastReadAtUpdated(TConversation conversation,TMessage message);
  void onMessageUpdated(TConversation conversation,TMessage message);
  void onMessageRecalled(TConversation conversation,TMessage message);
}

class ChatConversation {
  String convId;
  String creator;
  List<String> members;
  int unreadMessagesCount;
  ChatMessage lastMessage;
  int lastMessageAt;
  ChatConversation(this.convId,this.creator,this.members,this.unreadMessagesCount,this.lastMessage,this.lastMessageAt);
  ChatConversation.fromJson(Map data) : this(data['conversationId'],data['creator'],data['members'].cast<String>(),data['unreadMessagesCount'],ChatMessage.fromJson(data['lastMessage']),data['lastMessageAt']);
  ChatConversation.fromJsonString(String data) : this.fromJson(jsonDecode(data));
}

class ChatMessage {
  String msgId;
  String convId;
  String fromId;
  String text;
  int timestamp;
  String status;
  int receiptTimestamp;
  ChatMessage(this.msgId,this.convId,this.fromId,this.text,this.timestamp,this.status,this.receiptTimestamp);
  ChatMessage.fromJson(Map data) : this(data['messageId'],data['conversationId'],data['from'],data['text'],data['timestamp'],data['messageStatus'],data['receiptTimestamp']);
  ChatMessage.fromJsonString(String data) : this.fromJson(jsonDecode(data));
}

class ChatMessageStatus {
  static const String None = 'AVIMMessageStatusNone'; //未知
  static const String Sending = 'AVIMMessageStatusSending'; //发送中
  static const String Sent = 'AVIMMessageStatusSent'; //发送成功
  static const String Receipt = 'AVIMMessageStatusReceipt'; //被接收
  static const String Failed = 'AVIMMessageStatusFailed'; //失败
}