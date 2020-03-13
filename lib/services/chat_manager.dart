import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/event_manager.dart';
import 'package:social_foundation/states/chat_state.dart';
import 'package:social_foundation/states/user_state.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/utils/file_helper.dart';

abstract class SfChatManager<TConversation extends SfConversation,TMessage extends SfMessage> {
  final MethodChannel _channel = MethodChannel('social_foundation/chat');
  final EventChannel _eventChannel = EventChannel("social_foundation/chat/events");
  SfChatManager(String appId, String appKey, String serverURL){
    _channel.invokeMethod('initialize', {'appId': appId, 'appKey': appKey, 'serverURL': serverURL});
    _eventChannel.receiveBroadcastStream().listen(_handleEvent);
  }
  TConversation convertConversation(Map data);
  TMessage convertMessage(Map data);
  Future<TMessage> sendTextMsg({@required String convId,String msg,Map attribute}){
    return sendMsg(convId: convId,msg:msg,msgType:SfMessageType.text,attribute:attribute);
  }
  Future<TMessage> sendMsg({@required String convId,String msg,@required String msgType,Map msgExtra,Map attribute}) async {
    var message = convertMessage({
      'ownerId': GetIt.instance<SfUserState>().curUserId,
      'convId': convId,
      'fromId': GetIt.instance<SfUserState>().curUserId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'status': SfMessageStatus.Sending,
      'attribute': attribute,
      'msg': msg,
      'msgType': msgType,
      'msgExtra': msgExtra
    });
    resendMessage(message);
    return message;
  }
  Future<TMessage> resendMessage(TMessage message) async {
    try{
      //保存
      message.status = SfMessageStatus.Sending;
      message = await saveMessage(message);
      //上传
      String filePath = message.attribute['filePath'];
      if(filePath.isNotEmpty && !message.msgExtra.containsKey('fileKey')){
        await SfAliyunOss.uploadFile(dir:message.msgType,filePath: filePath);
        message.msgExtra['fileKey'] = SfFileHelper.getFileName(filePath);
        await saveMessage(message);
      }
      //发送
      var data = await sendMessage(message.convId, message.origin);
      message.msgId = data.msgId;
      message.status = data.status;
    }
    catch(e){
      message.status = SfMessageStatus.Failed;
    }
    return saveMessage(message);
  }
  saveConversation(TConversation conversation){
    GetIt.instance<SfChatState>().saveConversation(conversation);
  }
  Future<TMessage> saveMessage(TMessage message) async {
    var isNew = message.id==null;
    await message.save();
    SfMessageEvent.emit(message: message,isNew:isNew);
    if(message.fromOwner || !isNew){
      var conversation = await GetIt.instance<SfChatState>().queryConversation(message.convId);
      if(isNew || conversation.lastMessage.id==message.id){
        conversation.lastMessage = message;
        conversation.lastMessageAt = message.timestamp;
        saveConversation(conversation);
      }
    }
    return message;
  }
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
    map['ownerId'] = GetIt.instance<SfUserState>().curUserId;
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
    map['ownerId'] = GetIt.instance<SfUserState>().curUserId;
    map['msgId'] = data['messageId'];
    map['convId'] = data['conversationId'];
    map['fromId'] = data['from'];
    map['timestamp'] = data['timestamp'];
    map['status'] = data['messageStatus'];
    map['receiptTimestamp'] = data['receiptTimestamp'];
    map.addAll(json.decode(data['text']));
    return convertMessage(map);
  }
  //sdk
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
  void onMessageReceived(TConversation conversation,TMessage message){
    saveConversation(conversation);
    saveMessage(message);
  }
  void onUnreadMessagesCountUpdated(TConversation conversation, TMessage message) {
    saveConversation(conversation);
  }
  void onLastDeliveredAtUpdated(TConversation conversation,TMessage message){}
  void onLastReadAtUpdated(TConversation conversation,TMessage message){}
  void onMessageUpdated(TConversation conversation,TMessage message){}
  void onMessageRecalled(TConversation conversation,TMessage message){}
}