import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/states/user_state.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ChatManager extends SfChatManager<Conversation,Message> {
  static ChatManager get instance => GetIt.instance<SfChatManager>();

  ChatManager(String appId, String appKey, String serverURL) : super(appId,appKey,serverURL);
  Future<Message> sendTextMsg({@required String convId,String msg,Map attribute}){
    return sendMsg(convId: convId,msg:msg,msgType:SfMessageType.text,attribute:attribute);
  }
  Future<Message> sendMsg({@required String convId,String msg,@required String msgType,Map msgExtra,Map attribute}) async {
    var message = Message({
      'ownerId': UserState.instance.curUserId,
      'convId': convId,
      'fromId': UserState.instance.curUserId,
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

  @override
  Conversation convertConversation(Map data) => Conversation(data);
  @override
  Message convertMessage(Map data) => Message(data);
}