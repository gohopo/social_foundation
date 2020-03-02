import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/services/event_manager.dart';
import 'package:social_foundation_example/states/user_state.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../states/chat_state.dart';

class ChatManager extends SfChatManager<Conversation,Message> {
  static ChatManager get instance => GetIt.instance<ChatManager>();

  ChatManager(String appId, String appKey, String serverURL) : super(appId,appKey,serverURL);
  Future<Message> sendTextMsg({@required String convId,String msg,Map attribute}){
    return sendMsg(convId: convId,msg:msg,msgType:MessageType.text,attribute:attribute);
  }
  Future<Message> sendMsg({@required String convId,String msg,@required String msgType,Map attribute}) async {
    var data = {
      'msg': msg,
      'msgType': msgType
    };
    //保存
    Map message = Map.from(data);
    message['ownerId'] = UserState.instance.curUserId;
    message['convId'] = convId;
    message['fromId'] = UserState.instance.curUserId;
    message['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    message['status'] = SfMessageStatus.Sending;
    message['attribute'] = attribute;
    var result = await saveMessage(Message(message),true);
    //发送
    sendMessage(convId, json.encode(data)).then((data){
      result.msgId = data.msgId;
      result.status = data.status;
      saveMessage(result,false);
    }).catchError((data){
      result.status = SfMessageStatus.Failed;
      saveMessage(result,false);
    });
    return result;
  }
  saveConversation(Conversation conversation){
    ChatState.instance.saveConversation(conversation);
  }
  Future<Message> saveMessage(Message message,bool isNew) async {
    await message.save(isNew);
    MessageEvent.emit(message: message,isNew:isNew);
    if(message.fromOwner || !isNew){
      var conversation = await ChatState.instance.queryConversation(message.convId);
      if(isNew || conversation.lastMessage.id==message.id){
        conversation.lastMessage = message;
        conversation.lastMessageAt = message.timestamp;
        saveConversation(conversation);
      }
    }
    return message;
  }

  @override
  Conversation convertConversation(Map data) {
    data['ownerId'] = UserState.instance.curUserId;
    return Conversation(data);
  }
  @override
  Message convertMessage(Map data) {
    data['ownerId'] = UserState.instance.curUserId;
    return Message(data);
  }
  @override
  void onMessageReceived(Conversation conversation,Message message){
    saveConversation(conversation);
    saveMessage(message,true);
  }
  @override
  void onLastDeliveredAtUpdated(Conversation conversation, Message message) {

  }
  @override
  void onLastReadAtUpdated(Conversation conversation, Message message) {
  
  }
  @override
  void onMessageRecalled(Conversation conversation, Message message) {
  
  }
  @override
  void onMessageUpdated(Conversation conversation, Message message) {

  }
  @override
  void onUnreadMessagesCountUpdated(Conversation conversation, Message message) {
    saveConversation(conversation);
  }
}

class MessageType {
  static const String text = 'text';
  static const String image = 'image';
  static const String voice = 'voice';
}