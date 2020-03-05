import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/widgets/cached_image_provider.dart';

abstract class SfChatManager<TConversation extends SfConversation,TMessage extends SfMessage> {
  final MethodChannel _channel = MethodChannel('social_foundation/chat');
  final EventChannel _eventChannel = EventChannel("social_foundation/chat/events");
  SfChatManager(String appId, String appKey, String serverURL){
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
    return _convertMessage(result);
  }
  Future<List<TMessage>> queryMessages(String conversationId,int limit) async {
    var result = await _channel.invokeMethod('queryMessages',{'conversationId':conversationId,'limit':limit});
    List<dynamic> messages = json.decode(result);
    return messages.map((data) => _convertMessage(data)).toList();
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
  Future<void> convRead(String conversationId) {
    return _channel.invokeMethod('convRead',{'conversationId':conversationId});
  }
  TConversation convertConversation(Map data);
  TMessage convertMessage(Map data);
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
    var map = Map();
    map['convId'] = data['conversationId'];
    map['creator'] = data['creator'];
    map['members'] = data['members'].cast<String>();
    map['unreadMessagesCount'] = data['unreadMessagesCount'];
    map['lastMessage'] = _convertMessage(data['lastMessage']);
    map['lastMessageAt'] = data['lastMessageAt'];
    return convertConversation(map);
  }
  TMessage _convertMessage(Map data){
    var map = Map();
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

class SfConversation<TMessage extends SfMessage> {
  int id;
  String ownerId;
  String convId;
  String creator;
  List<String> members;
  int unreadMessagesCount;
  TMessage lastMessage;
  int lastMessageAt;
  SfConversation(Map data) : id = data['id'],ownerId = data['ownerId'],convId = data['convId'],creator = data['creator'],members = data['members'],unreadMessagesCount = data['unreadMessagesCount'],lastMessage = data['lastMessage'],lastMessageAt = data['lastMessageAt'];
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['ownerId'] = ownerId;
    map['convId'] = convId;
    map['creator'] = creator;
    map['members'] = json.encode(members);
    map['unreadMessagesCount'] = unreadMessagesCount;
    map['lastMessage'] = json.encode(lastMessage.toMap());
    map['lastMessageAt'] = lastMessageAt;
    return map;
  }
  String get otherId => members.firstWhere((userId) => userId!=ownerId,orElse: ()=>null);
}

class SfMessage {
  int id;
  String ownerId;
  String msgId;
  String convId;
  String fromId;
  int timestamp;
  String status;
  int receiptTimestamp;
  Map attribute;
  String msg;
  String msgType;
  Map msgExtra;
  SfMessage(Map data) : id = data['id'],ownerId = data['ownerId'],msgId = data['msgId'],convId = data['convId'],fromId = data['fromId'],timestamp = data['timestamp'],status = data['status'],receiptTimestamp = data['receiptTimestamp'],attribute = data['attribute'],msg = data['msg'],msgType = data['msgType'],msgExtra = data['msgExtra'];
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['ownerId'] = ownerId;
    map['attribute'] = attribute!=null ? json.encode(attribute) : null;
    map['msgId'] = msgId;
    map['convId'] = convId;
    map['fromId'] = fromId;
    map['timestamp'] = timestamp;
    map['status'] = status;
    map['receiptTimestamp'] = receiptTimestamp;
    map['msg'] = msg;
    map['msgType'] = msgType;
    map['msgExtra'] = msgExtra!=null ? json.encode(msgExtra) : null;
    return map;
  }
  bool get fromOwner => fromId==ownerId;
  String get origin{
    Map<String,dynamic> map = {'msgType':msgType};
    if(msg != null) map['msg'] = msg;
    if(msgExtra != null) map['msgExtra'] = msgExtra;
    return json.encode(map);
  }
  String get des{
    switch(msgType){
      case SfMessageType.text:
        return msg;
      case SfMessageType.image:
        return '[图片]';
      case SfMessageType.voice:
        return '[声音]';
      default:
        return '';
    }
  }
  String resolveFileUri(){
    if(attribute!=null && attribute['filePath']!=null) return attribute['filePath'];
    if(msgExtra!=null && msgExtra['fileKey']!=null) return SfAliyunOss.getImageUrl(msgExtra['fileKey']);
    return '';
  }
  ImageProvider resolveImage(){
    if(attribute!=null && attribute['filePath']!=null) return FileImage(File(attribute['filePath']));
    if(msgExtra!=null && msgExtra['fileKey']!=null) return SfCachedImageProvider(SfAliyunOss.getImageUrl(msgExtra['fileKey']));
    return null;
  }
}

class SfMessageStatus {
  static const String None = 'AVIMMessageStatusNone'; //未知
  static const String Sending = 'AVIMMessageStatusSending'; //发送中
  static const String Sent = 'AVIMMessageStatusSent'; //发送成功
  static const String Receipt = 'AVIMMessageStatusReceipt'; //被接收
  static const String Failed = 'AVIMMessageStatusFailed'; //失败
}

class SfMessageType {
  static const String text = 'text';
  static const String image = 'image';
  static const String voice = 'voice';
}