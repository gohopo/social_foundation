import 'dart:convert';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/state/user_state.dart';
import '../model/message.dart';
import '../model/conversation.dart';
import '../state/chat_state.dart';

class ChatManager extends ChatEventManager<Conversation,Message> {
  static ChatManager get instance => GetIt.instance<ChatManager>();

  ChatManager(String appId, String appKey, String serverURL) : super(appId,appKey,serverURL);
  Future<Message> sendTextMsg({@required String convId,String msg,Map<String,dynamic> attribute}){
    return sendMsg(convId: convId,msg:msg,msgType:MessageType.text,attribute:attribute);
  }
  Future<Message> sendImageMsg({@required String convId,String path,Map<String,dynamic> attribute}){
    var msg = path;
    return sendMsg(convId: convId,msg:msg,msgType:MessageType.image,attribute:attribute);
  }
  Future<Message> sendMsg({@required String convId,String msg,@required String msgType,Map<String,dynamic> attribute}){
    Map<String,dynamic> message = {
      'msg': msg,
      'msgType': msgType
    };
    //mock
    message['ownerId'] = UserState.instance.curUserId;
    message['convId'] = convId;
    message['fromId'] = UserState.instance.curUserId;
    message['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    message['status'] = ChatMessageStatus.Sending;
    var result = Message(message).insert();
    return result;
    //return sendMessage(convId, json.encode(message));
  }
  saveConversation(Conversation conversation){
    ChatState.instance.saveConversation(conversation);
  }
  saveMessage(Message message) async {
    await message.insert();
    GetIt.instance<EventBus>().fire(message);
  }

  @override
  Conversation convertConversation(Map<String,dynamic> data) {
    data['ownerId'] = UserState.instance.curUserId;
    return Conversation(data);
  }
  @override
  Message convertMessage(Map<String,dynamic> data) {
    data['ownerId'] = UserState.instance.curUserId;
    return Message(data);
  }
  @override
  void onMessageReceived(Conversation conversation,Message message){
    saveConversation(conversation);
    saveMessage(message);
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

  }
}

class MessageType {
  static final String text = 'text';
  static final String image = 'image';
  static final String voice = 'voice';
}