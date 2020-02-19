import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

abstract class ChatEventManager<TConversation extends ChatConversation,TMessage extends ChatMessage> {
  final MethodChannel _channel = MethodChannel('social_foundation/chat');
  final EventChannel _eventChannel = EventChannel("social_foundation/chat/events");
  ChatEventManager(String appId, String appKey, String serverURL){
    _channel.invokeMethod('initialize', {'appId': appId, 'appKey': appKey, 'serverURL': serverURL});
    _eventChannel.receiveBroadcastStream().listen(_handleEvent);
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
  TConversation convertConversation(Map<String,dynamic> data);
  TMessage convertMessage(Map<String,dynamic> data);
  void onMessageReceived(TConversation conversation,TMessage message);
  void onUnreadMessagesCountUpdated(TConversation conversation,TMessage message);
  void onLastDeliveredAtUpdated(TConversation conversation,TMessage message);
  void onLastReadAtUpdated(TConversation conversation,TMessage message);
  void onMessageUpdated(TConversation conversation,TMessage message);
  void onMessageRecalled(TConversation conversation,TMessage message);

  void _handleEvent(data){
    String event = data['event'];
    var conversation = _convertConversation(data['conversation']);
    var message = _convertMessage(data['message']);
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
  TConversation _convertConversation(String conversation){
    if(conversation == null) return null;
    var data = json.decode(conversation);
    var map = new Map<String,dynamic>();
    map['convId'] = data['conversationId'];
    map['creator'] = data['creator'];
    map['members'] = data['members'].cast<String>();
    map['unreadMessagesCount'] = data['unreadMessagesCount'];
    map['lastMessage'] = _convertMessage(data['lastMessage']);
    map['lastMessageAt'] = data['lastMessageAt'];
    return convertConversation(map);
  }
  TMessage _convertMessage(String message){
    if(message == null) return null;
    var data = json.decode(message);
    var map = new Map<String,dynamic>();
    map['msgId'] = data['messageId'];
    map['convId'] = data['conversationId'];
    map['fromId'] = data['from'];
    map['message'] = data['text'];
    map['timestamp'] = data['timestamp'];
    map['status'] = data['messageStatus'];
    map['receiptTimestamp'] = data['receiptTimestamp'];
    return convertMessage(map);
  }
}

class ChatConversation<TMessage extends ChatMessage> {
  String convId;
  String creator;
  List<String> members;
  int unreadMessagesCount;
  TMessage lastMessage;
  int lastMessageAt;
  ChatConversation(Map<String,dynamic> data) : convId = data['convId'],creator = data['creator'],members = data['members'],unreadMessagesCount = data['unreadMessagesCount'],lastMessage = data['lastMessage'],lastMessageAt = data['lastMessageAt'];
  toMap(){
    var map = new Map<String,dynamic>();
    map['convId'] = convId;
    map['creator'] = creator;
    map['members'] = members.toString();
    map['unreadMessagesCount'] = unreadMessagesCount;
    map['lastMessage'] = lastMessage.toMap();
    map['lastMessageAt'] = lastMessageAt;
    return map;
  }
}

class ChatMessage {
  String msgId;
  String convId;
  String fromId;
  String message;
  int timestamp;
  String status;
  int receiptTimestamp;
  ChatMessage(Map<String,dynamic> data) : msgId = data['msgId'],convId = data['convId'],fromId = data['fromId'],message = data['message'],timestamp = data['timestamp'],status = data['status'],receiptTimestamp = data['receiptTimestamp'];
  toMap(){
    var map = new Map<String,dynamic>();
    map['msgId'] = msgId;
    map['convId'] = convId;
    map['fromId'] = fromId;
    map['message'] = message;
    map['timestamp'] = timestamp;
    map['status'] = status;
    map['receiptTimestamp'] = receiptTimestamp;
    return map;
  }
}

class ChatMessageStatus {
  static const String None = 'AVIMMessageStatusNone'; //未知
  static const String Sending = 'AVIMMessageStatusSending'; //发送中
  static const String Sent = 'AVIMMessageStatusSent'; //发送成功
  static const String Receipt = 'AVIMMessageStatusReceipt'; //被接收
  static const String Failed = 'AVIMMessageStatusFailed'; //失败
}