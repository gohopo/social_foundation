import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/service/event_manager.dart';
import 'package:social_foundation_example/state/user_state.dart';
import '../model/message.dart';
import '../model/conversation.dart';
import '../state/chat_state.dart';

class ChatManager extends ChatEventManager<Conversation,Message> {
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
    message['status'] = ChatMessageStatus.Sending;
    message['attribute'] = attribute;
    var result = await saveMessage(Message(message));
    //发送
    sendMessage(convId, json.encode(data)).then((data){
      result.msgId = data.msgId;
      result.status = data.status;
      updateMessage(result);
    }).catchError((data){
      result.status = ChatMessageStatus.Failed;
      updateMessage(result);
    });
    return result;
  }
  saveConversation(Conversation conversation){
    ChatState.instance.saveConversation(conversation);
  }
  Future<Message> saveMessage(Message message) async {
    await message.insert();
    MessageEvent.emit(message: message);
    return message;
  }
  Future<void> updateMessage(Message message) async {
    await message.update();
    MessageEvent.emit(message: message,isNew: false);
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