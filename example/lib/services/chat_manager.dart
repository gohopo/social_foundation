import 'package:flutter/cupertino.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/chat_manager.dart';
import 'package:social_foundation_example/models/conversation.dart';
import 'package:social_foundation_example/models/message.dart';

class ChatManager extends SfChatManager<Conversation,Message> {
  Future<Message> sendTextMsg({@required String convId,String msg,Map attribute}){
    return sendMsg(convId: convId,msg:msg,msgType:SfMessageType.text,attribute:attribute);
  }
  @override
  Conversation convertConversation(Map data) => Conversation(data);
  @override
  Message convertMessage(Map data) => Message(data);
}