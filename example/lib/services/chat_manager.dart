import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ChatManager extends SfChatManager<Conversation,Message> {
  static ChatManager get instance => GetIt.instance<SfChatManager>();

  Future<Message> sendTextMsg({@required String convId,String msg,Map attribute}){
    return sendMsg(convId: convId,msg:msg,msgType:SfMessageType.text,attribute:attribute);
  }
  @override
  Conversation convertConversation(Map data) => Conversation(data);
  @override
  Message convertMessage(Map data) => Message(data);
}