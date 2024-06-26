import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/event_manager.dart';
import 'package:social_foundation/services/locator_manager.dart';
import 'package:social_foundation/utils/aliyun_helper.dart';
import 'package:social_foundation/utils/file_helper.dart';

abstract class SfChatManager<TConversation extends SfConversation,TMessage extends SfMessage> {
  late Client _client;
  TConversation convertConversation(Map data);
  TMessage convertMessage(Map data);
  Future<TMessage> sendSystemMsg({required String convId,String? msg,String? systemType,Map? msgExtra}){
    if(msgExtra == null) msgExtra = {};
    msgExtra['systemType'] = systemType;
    return sendMsg(convId:convId,msg:msg,msgType:SfMessageType.system,msgExtra:msgExtra);
  }
  Future<TMessage> sendNotifyMsg({required String convId,required String notifyType,Map? msgExtra}) => _sendMessage(convId,null,SfMessageType.notify,{...msgExtra??{},'notifyType':notifyType,'transient':true});
  Future<TMessage> sendMsg({required String convId,String? msg,required String msgType,Map? msgExtra,Map? attribute,bool? transient,bool? saveConv}) async {
    var message = convertMessage({
      'ownerId': SfLocatorManager.userState.curUserId,
      'convId': convId,
      'fromId': SfLocatorManager.userState.curUserId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'status': MessageStatus.sending.index,
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
        var data = await _sendMessage(message.convId,message.msg,message.msgType,message.msgExtra);
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
  Future<TMessage> recallMessage(TMessage message) async {
    await convRecall(message.convId, message.msgId, message.timestamp);
    message.msgType = SfMessageType.recall;
    return saveMessage(message);
  }
  void saveConversation(TConversation conversation,{bool? fromReceived,bool? unreadMessageCountUpdated}) => SfLocatorManager.chatState.saveConversation(conversation,fromReceived:fromReceived,unreadMessageCountUpdated:unreadMessageCountUpdated);
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
  TConversation _convertConversation(Conversation conversation){
    var map = Map();
    map['ownerId'] = SfLocatorManager.userState.curUserId;
    map['convId'] = conversation.id;
    map['name'] = conversation.name;
    map['creator'] = conversation.creator;
    map['members'] = conversation.members;
    map['unreadMessagesCount'] = conversation.unreadMessageCount;
    map['lastMessage'] = _convertMessage(conversation.lastMessage);
    map['lastMessageAt'] = conversation.lastMessage?.sentTimestamp;
    return convertConversation(map);
  }
  TMessage? _convertMessage(Message? message){
    if(message==null) return null;
    var map = Map();
    map['ownerId'] = SfLocatorManager.userState.curUserId;
    map['msgId'] = message.id;
    map['convId'] = message.conversationID;
    map['fromId'] = message.fromClientID;
    map['timestamp'] = message.sentTimestamp;
    map['status'] = message.status.index;
    map['receiptTimestamp'] = message.deliveredTimestamp;
    if(message is TextMessage){
      map.addAll(json.decode(message.text!));
    }
    else if(message is RecalledMessage){
      map['msgType'] = SfMessageType.recall;
    }
    return convertMessage(map);
  }
  //sdk
  Future login(String userId) {
    _client = Client(id:userId);
    _client.onDisconnected = ({required client,exception}) => onClientDisconnected();
    _client.onResuming = ({required client}) => onClientResuming();
    _client.onMessage = ({required client,required conversation,required message}) => onMessageReceived(_convertConversation(conversation),_convertMessage(message)!);
    _client.onUnreadMessageCountUpdated = ({required client,required conversation}) => onUnreadMessagesCountUpdated(_convertConversation(conversation));
    _client.onMessageRecalled = ({required client,required conversation,required recalledMessage}) => onMessageRecalled(_convertMessage(recalledMessage)!);
    return _client.open();
  }
  Future close() async {
    await _client.close();
  }
  Future reconnect() => _client.open(reconnect:true);
  Future<TConversation> getConversation(String conversationId) async {
    var conversation = await _getConversation(conversationId);
    return _convertConversation(conversation);
  }
  Future<List<TMessage>> queryMessages(String conversationId,int limit) async {
    var conversation = await _getConversation(conversationId);
    List<TMessage> messages = [];
    TMessage? startMessage;
    while(limit > 0){
      var count = min(limit,100);
      var result = await conversation.queryMessage(startMessageID:startMessage?.msgId,startTimestamp:startMessage?.timestamp,startClosed:startMessage!=null?false:null,limit:count);
      messages.addAll(result.map((data) => _convertMessage(data)!));
      startMessage = messages.lastOrNull;
      limit -= count;
    }
    return messages;
  }
  Future<TConversation> convCreate(String name,List<String> members,bool isUnique,Map<String,dynamic> attributes) async {
    var result = await _client.createConversation(name:name,members:members.toSet(),isUnique:isUnique,attributes:attributes);
    return _convertConversation(result);
  }
  Future<TConversation> convJoin(String conversationId) async {
    var conversation = await _getConversation(conversationId);
    await conversation.join();
    return _convertConversation(conversation);
  }
  Future convQuit(String conversationId) async {
    var conversation = await _getConversation(conversationId);
    await conversation.quit();
  }
  Future convInvite(String conversationId,List<String> members) async {
    var conversation = await _getConversation(conversationId);
    await conversation.addMembers(members: members.toSet());
  }
  Future convKick(String conversationId,List<String> members) async {
    var conversation = await _getConversation(conversationId);
    await conversation.removeMembers(members: members.toSet());
  }
  Future convRead(String conversationId) async {
    var conversation = await _getConversation(conversationId);
    return conversation.read();
  }
  Future convRecall(String conversationId,String? messageID,int? timestamp) async {
    var conversation = await _getConversation(conversationId);
    return conversation.recallMessage(messageID:messageID,messageTimestamp:timestamp);
  }
  void onClientDisconnected(){
    SfClientDisconnectedEvent().emit();
  }
  void onClientResuming(){
    SfClientResumingEvent().emit();
  }
  void onMessageReceived(TConversation conversation,TMessage message){
    if(message.msgType==SfMessageType.notify) return onNotifyReceived(message);
    if(!message.transient) saveConversation(conversation,fromReceived:true);
    saveMessage(message,true);
  }
  void onUnreadMessagesCountUpdated(TConversation conversation) async {
    if(conversation.unreadMessagesCount<=0)  return;
    saveConversation(conversation,unreadMessageCountUpdated:true);
    convRead(conversation.convId);
    SfUnreadMessagesCountUpdatedEvent<TConversation>(conversation:conversation).emit();
  }
  void onMessageRecalled(TMessage message){
    saveMessage(message,false);
  }
  void onNotifyReceived(TMessage message) => SfLocatorManager.appState.addNotify(notifyType:message.msgExtra['notifyType'],fromId:message.fromId);
  Future<Conversation> _getConversation(String conversationId) async {
    var conversation = _client.conversationMap[conversationId];
    if(conversation == null){
      var query = _client.conversationQuery();
      query.whereString = jsonEncode({
        'objectId': conversationId,
      });
      query.limit = 1;
      var result = await query.find();
      if(result.length == 0) throw '未查询到会话!';
      conversation = result[0];
    }
    return conversation;
  }
  Future<TMessage> _sendMessage(String conversationId,String? msg,String msgType,Map msgExtra) async {
    var conversation = await _getConversation(conversationId);
    var message = json.encode({
      'msg': msg,
      'msgType': msgType,
      'msgExtra': msgExtra
    });
    var result = await hookSendMessage(conversation,TextMessage.from(text:message),msgExtra['transient']??false);
    return _convertMessage(result)!;
  }
  Future<Message> hookSendMessage(Conversation conversation,Message message,bool transient){
    return conversation.send(message:message,transient:transient);
  }
}