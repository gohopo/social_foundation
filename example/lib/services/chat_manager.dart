import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_example/services/event_manager.dart';
import 'package:social_foundation_example/states/user_state.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../states/chat_state.dart';

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
  Future<Message> resendMessage(Message message) async {
    try{
      //保存
      message.status = SfMessageStatus.Sending;
      message = await saveMessage(message);
      //上传
      String filePath = message.attribute['filePath'];
      if(filePath.isNotEmpty && !message.msgExtra.containsKey('fileKey')){
        await SfAliyunOss.uploadFile(dir:message.msgType,filePath: filePath);
        print(SfFileHelper.getFileName(filePath));
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
  saveConversation(Conversation conversation){
    ChatState.instance.saveConversation(conversation);
  }
  Future<Message> saveMessage(Message message) async {
    var isNew = message.id==null;
    await message.save();
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
    saveConversation(conversation);
  }
}