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
  Future<TMessage?> getMessage({int? id,String? msgId});
  Future init() async {}
  Future login(String userId,{String? token});
  TMessage messageFactory(Map data);
  TMessage messageFactory2({required String convId,String? msg,String? msgType,Map? msgExtra,Map? attribute,String? fromId,int? timestamp,int? status}) => messageFactory({
    'ownerId': SfLocatorManager.userState.curUserId,
    'convId': convId,
    'fromId': fromId??SfLocatorManager.userState.curUserId,
    'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
    'status': status??SfMessageStatus.sending,
    'msg': msg,
    'msgType': msgType??SfMessageType.text,
    'msgExtra': msgExtra,
    'attribute': attribute,
  });
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
  void onSendError(String? error){
    SfLocatorManager.appState.showError(error);
  }
  void protectedOnSendError(dynamic error){}
  Future<TMessage> protectedSendMessage(String conversationId,String? msg,String msgType,Map msgExtra);
  Future<TConversation> queryChatWith(String userId,{bool? save=true,String? noAccessError});
  Future<TMessage> recallMessage(TMessage message) async {
    await convRecall(message.msgId!,conversationId:message.convId,timestamp:message.timestamp);
    message.msgType = SfMessageType.recall;
    return saveMessage(message);
  }
  Future reconnect() async {}
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
      protectedOnSendError(e);
    }
    return saveMessage(message);
  }
  void saveConversation(TConversation conversation,{bool? fromReceived,bool? unreadMessageCountUpdated}){
    conversation.save();
    SfLocatorManager.chatState.updateConversation(conversation);
  }
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
  Future<TMessage> saveMessage2({required String convId,String? msg,String? msgType,Map? msgExtra,Map? attribute,String? fromId,int? timestamp,int? status}){
    var message = messageFactory2(
      convId:convId,msg:msg,msgType:msgType,msgExtra:msgExtra,
      attribute:attribute,fromId:fromId,timestamp:timestamp,status:status??SfMessageStatus.sent
    );
    return saveMessage(message,true);
  }
  Future<TMessage> saveMessage3({required String otherId,String? msg,String? msgType,Map? msgExtra,Map? attribute,String? fromId,int? timestamp,int? status}) async {
    var conversation = await queryChatWith(otherId,save:false);
    return saveMessage2(
      convId:conversation.convId,msg:msg,msgType:msgType,msgExtra:msgExtra,
      attribute:attribute,fromId:fromId,timestamp:timestamp,status:status
    );
  }
  Future<TMessage> sendMsg({required String convId,String? msg,required String msgType,Map? msgExtra,Map? attribute,bool? transient,bool? saveConv}) async {
    var message = messageFactory2(
      convId:convId,msg:msg,msgType:msgType,msgExtra:msgExtra,attribute:attribute
    );
    if(transient!=null) message.msgExtra['transient'] = transient;
    if(saveConv!=null) message.attribute['saveConv'] = saveConv;
    resendMessage(message);
    return message;
  }
  Future<TMessage> sendNotifyMsg({required String convId,required String notifyType,Map? msgExtra}) => protectedSendMessage(convId,null,SfMessageType.notify,{...msgExtra??{},'notifyType':notifyType,'transient':true});
  Future<TMessage> sendSystemMsg({required String convId,String? msg,String? systemType,Map? msgExtra,bool? saveConv}){
    msgExtra ??= {};
    msgExtra['systemType'] = systemType;
    return sendMsg(convId:convId,msg:msg,msgType:SfMessageType.system,msgExtra:msgExtra,saveConv:saveConv);
  }
}