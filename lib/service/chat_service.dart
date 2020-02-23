import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  @protected Future<TMessage> sendMessage(String conversationId,String message) async {
    var result = await _channel.invokeMethod('sendMessage',{'conversationId':conversationId,'message':message});
    return convertMessage(result);
  }
  Future<TConversation> convCreate(String name,List<String> members,bool isUnique,Map attributes,bool isTransient) async {
    try{
      var result = await _channel.invokeMethod('convCreate',{'name':name,'members':members,'isUnique':isUnique,'attributes':attributes,'isTransient':isTransient});
      return _convertConversation(json.decode(result));
    }
    catch(e){
      return null;
    }
  }
  Future<void> convJoin(String conversationId){
    return _channel.invokeMethod('convJoin',{'conversationId':conversationId});
  }
  Future<void> convQuit(String conversationId){
    return _channel.invokeMethod('convQuit',{'conversationId':conversationId});
  }
  Future<void> convInvite(String conversationId,List<String> members){
    return _channel.invokeMethod('convInvite',{'conversationId':conversationId,'members':members});
  }
  Future<void> convKick(String conversationId,List<String> members){
    return _channel.invokeMethod('convKick',{'conversationId':conversationId,'members':members});
  }
  void convRead(String conversationId) {
    _channel.invokeMethod('convRead');
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
    var conversation = data['conversation']==null ? null : _convertConversation(json.decode(data['conversation']));
    var message = data['message']==null ? null : _convertMessage(json.decode(data['message']));
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
  TConversation _convertConversation(Map data){
    var map = new Map<String,dynamic>();
    map['convId'] = data['conversationId'];
    map['creator'] = data['creator'];
    map['members'] = data['members'].cast<String>();
    map['unreadMessagesCount'] = data['unreadMessagesCount'];
    map['lastMessage'] = _convertMessage(data['lastMessage']);
    map['lastMessageAt'] = data['lastMessageAt'];
    return convertConversation(map);
  }
  TMessage _convertMessage(Map data){
    var map = new Map<String,dynamic>();
    map['msgId'] = data['messageId'];
    map['convId'] = data['conversationId'];
    map['fromId'] = data['from'];
    map['timestamp'] = data['timestamp'];
    map['status'] = data['messageStatus'];
    map['receiptTimestamp'] = data['receiptTimestamp'];
    map.addAll(json.decode(data['text']));
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
  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['convId'] = convId;
    map['creator'] = creator;
    map['members'] = json.encode(members);
    map['unreadMessagesCount'] = unreadMessagesCount;
    map['lastMessage'] = json.encode(lastMessage.toMap());
    map['lastMessageAt'] = lastMessageAt;
    return map;
  }
}

class ChatMessage {
  String msgId;
  String convId;
  String fromId;
  int timestamp;
  String status;
  int receiptTimestamp;
  String msg;
  String msgType;
  Map<String,dynamic> attribute;
  ChatMessage(Map<String,dynamic> data) : msgId = data['msgId'],convId = data['convId'],fromId = data['fromId'],timestamp = data['timestamp'],status = data['status'],receiptTimestamp = data['receiptTimestamp'],msg = data['msg'],msgType = data['msgType'],attribute = data['attribute'];
  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['msgId'] = msgId;
    map['convId'] = convId;
    map['fromId'] = fromId;
    map['timestamp'] = timestamp;
    map['status'] = status;
    map['receiptTimestamp'] = receiptTimestamp;
    map['msg'] = msg;
    map['msgType'] = msgType;
    map['attribute'] = attribute!=null ? json.encode(attribute) : null;
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