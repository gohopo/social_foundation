import 'dart:async';

import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/event_manager.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/utils/aliyun_helper.dart';
import 'package:social_foundation/utils/file_helper.dart';

abstract class SfChatManager<TConversation extends SfConversation,TMessage extends SfMessage>{
  Future close();
  TConversation conversationFactory(Map data);
  Future<TConversation> convJoin(String conversationId);
  Future convQuit(String conversationId);
  Future convRead(String conversationId);
  Future convRecall(String messageID,{String? conversationId,int? timestamp});
  Future<TConversation> getConversation(String conversationId);
  Future init() async {}
  Future login(String userId,{String? token});
  TMessage messageFactory(Map data);
  void onClientDisconnected(){
    SfClientDisconnectedEvent().emit();
  }
  void onClientResuming(){
    SfClientResumingEvent().emit();
  }
  void onMessageRecalled(TMessage message){
    message.msgType = SfMessageType.recall;
    saveMessage(message,false);
  }
  void onMessageReceived(TMessage message){
    if(message.msgType==SfMessageType.notify) return onNotifyReceived(message);
    saveMessage(message,true);
  }
  void onNotifyReceived(TMessage message) => SfLocatorManager.appState.addNotify(notifyType:message.msgExtra['notifyType'],fromId:message.fromId);
  Future<TMessage> protectedSendMessage(String conversationId,String? msg,String msgType,Map msgExtra);
  Future<TMessage> recallMessage(TMessage message) async {
    await convRecall(message.msgId!,conversationId:message.convId,timestamp:message.timestamp);
    message.msgType = SfMessageType.recall;
    return saveMessage(message);
  }
  Future reconnect();
  Future<TMessage> resendMessage(TMessage message) async {
    try{
      //保存
      message.status = SfMessageStatus.sending;
      message = await saveMessage(message,message.id==null);
      //上传
      String? filePath = message.attribute['filePath'];
      if(filePath!=null && !message.msgExtra.containsKey('fileKey')){
        await SfAliyunOss.uploadFile(message.attribute['fileDir'],filePath);
        message.msgExtra['fileKey'] = SfFileHelper.getFileName(filePath);
        await saveMessage(message);
      }
      //发送
      if(message.attribute['fakeSend']==true){
        message.status = SfMessageStatus.sent;
      }
      else{
        var data = await protectedSendMessage(message.convId,message.msg,message.msgType,message.msgExtra);
        message.msgId = data.msgId;
        message.timestamp = data.timestamp;
        message.status = data.status;
      }
    }
    catch(e){
      message.status = SfMessageStatus.failed;
    }
    return saveMessage(message);
  }
  void saveConversation(TConversation conversation,{bool? fromReceived,bool? unreadMessageCountUpdated});
  Future<TMessage> saveMessage(TMessage message,[bool isNew=false]) async {
    if(!message.transient) await message.save();
    SfMessageEvent(message:message,isNew:isNew).emit();
    if(!message.transient && message.attribute['saveConv']!=false && (message.fromOwner || !isNew)){
      var conversation = await SfLocatorManager.chatState.queryConversation(message.convId);
      if(conversation!=null && (isNew || conversation.lastMessage==null || conversation.lastMessage?.id==message.id)){
        conversation.lastMessage = message;
        conversation.lastMessageAt = message.timestamp;
        saveConversation(conversation as TConversation);
      }
    }
    return message;
  }
  Future<TMessage> sendMsg({required String convId,String? msg,required String msgType,Map? msgExtra,Map? attribute,bool? transient,bool? saveConv}) async {
    var message = messageFactory({
      'ownerId': SfLocatorManager.userState.curUserId,
      'convId': convId,
      'fromId': SfLocatorManager.userState.curUserId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'status': SfMessageStatus.sending,
      'attribute': attribute,
      'msg': msg,
      'msgType': msgType,
      'msgExtra': msgExtra
    });
    if(transient!=null) message.msgExtra['transient'] = transient;
    if(saveConv!=null) message.attribute['saveConv'] = saveConv;
    resendMessage(message);
    return message;
  }
  Future<TMessage> sendNotifyMsg({required String convId,required String notifyType,Map? msgExtra}) => protectedSendMessage(convId,null,SfMessageType.notify,{...msgExtra??{},'notifyType':notifyType,'transient':true});
  Future<TMessage> sendSystemMsg({required String convId,String? msg,String? systemType,Map? msgExtra}){
    msgExtra ??= {};
    msgExtra['systemType'] = systemType;
    return sendMsg(convId:convId,msg:msg,msgType:SfMessageType.system,msgExtra:msgExtra);
  }
}