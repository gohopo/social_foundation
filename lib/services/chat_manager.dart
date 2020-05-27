import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/event_manager.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation/states/chat_state.dart';
import 'package:social_foundation/states/user_state.dart';
import 'package:social_foundation/utils/aliyun_oss.dart';
import 'package:social_foundation/utils/file_helper.dart';

abstract class SfChatManager<TConversation extends SfConversation,TMessage extends SfMessage> {
  Client _client;
  SfChatManager(String appId, String appKey, String serverURL){
    SocialFoundation.initialize(appId, appKey, serverURL);
  }
  TConversation convertConversation(Map data);
  TMessage convertMessage(Map data);
  Future<TMessage> sendTextMsg({@required String convId,String msg,Map attribute}){
    return sendMsg(convId:convId,msg:msg,msgType:SfMessageType.text,attribute:attribute);
  }
  Future<TMessage> sendSystemMsg({@required String convId,@required String systemType,Map msgExtra}){
    if(msgExtra == null) msgExtra = {};
    msgExtra['systemType'] = systemType;
    return sendMsg(convId:convId,msgType:SfMessageType.system,msgExtra:msgExtra);
  }
  Future<TMessage> sendNotifyMsg({@required String convId,@required String notifyType}) => _sendMessage(convId,null,SfMessageType.notify,{'notifyType':notifyType},transient:true);
  Future<TMessage> sendMsg({@required String convId,String msg,@required String msgType,Map msgExtra,Map attribute}) async {
    var message = convertMessage({
      'ownerId': GetIt.instance<SfUserState>().curUserId,
      'convId': convId,
      'fromId': GetIt.instance<SfUserState>().curUserId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'status': MessageStatus.sending.index,
      'attribute': attribute,
      'msg': msg,
      'msgType': msgType,
      'msgExtra': msgExtra
    });
    resendMessage(message);
    return message;
  }
  Future<TMessage> resendMessage(TMessage message) async {
    try{
      //保存
      message.status = SfMessageStatus.sending;
      message = await saveMessage(message);
      //上传
      String filePath = message.attribute['filePath'];
      if(filePath!=null && !message.msgExtra.containsKey('fileKey')){
        await SfAliyunOss.uploadFile(message.attribute['fileDir'],filePath);
        message.msgExtra['fileKey'] = SfFileHelper.getFileName(filePath);
        await saveMessage(message);
      }
      //发送
      var data = await _sendMessage(message.convId,message.msg,message.msgType,message.msgExtra);
      message.msgId = data.msgId;
      message.status = data.status;
    }
    catch(e){
      message.status = SfMessageStatus.failed;
    }
    return saveMessage(message);
  }
  saveConversation(TConversation conversation){
    GetIt.instance<SfChatState>().saveConversation(conversation);
  }
  Future<TMessage> saveMessage(TMessage message) async {
    var isNew = message.id==null;
    await message.save();
    SfMessageEvent(message: message,isNew:isNew).emit();
    if(message.fromOwner || !isNew){
      var conversation = await GetIt.instance<SfChatState>().queryConversation(message.convId);
      if(conversation!=null && (isNew || conversation.lastMessage==null || conversation.lastMessage.id==message.id)){
        conversation.lastMessage = message;
        conversation.lastMessageAt = message.timestamp;
        saveConversation(conversation);
      }
    }
    return message;
  }
  TConversation _convertConversation(Conversation conversation){
    var map = Map();
    map['ownerId'] = GetIt.instance<SfUserState>().curUserId;
    map['convId'] = conversation.id;
    map['creator'] = conversation.creator;
    map['members'] = conversation.members;
    map['unreadMessagesCount'] = conversation.unreadMessageCount ?? 0;
    map['lastMessage'] = conversation.lastMessage!=null ? _convertMessage(conversation.lastMessage) : null;
    map['lastMessageAt'] = conversation.lastDeliveredAt;
    return convertConversation(map);
  }
  TMessage _convertMessage(Message message){
    var map = Map();
    map['ownerId'] = GetIt.instance<SfUserState>().curUserId;
    map['msgId'] = message.id;
    map['convId'] = message.conversationID;
    map['fromId'] = message.fromClientID;
    map['timestamp'] = message.sentTimestamp;
    map['status'] = message.status.index;
    map['receiptTimestamp'] = message.deliveredTimestamp;
    var text = (message as TextMessage).text;
    map.addAll(json.decode(text));
    return convertMessage(map);
  }
  //sdk
  Future login(String userId) {
    _client = Client(id:userId);
    _client.onMessage = ({client,conversation,message}) => onMessageReceived(_convertConversation(conversation),_convertMessage(message));
    _client.onUnreadMessageCountUpdated = ({client,conversation}) => onUnreadMessagesCountUpdated(_convertConversation(conversation));
    return _client.open();
  }
  Future close() async {
    await _client?.close();
    _client = null;
  }
  Future<TConversation> getConversation(String conversationId) async {
    var conversation = await _getConversation(conversationId);
    return conversation!=null ? _convertConversation(conversation) : null;
  }
  Future<List<TMessage>> queryMessages(String conversationId,int limit) async {
    var conversation = await _getConversation(conversationId);
    var result = await conversation.queryMessage(limit:limit);
    return result.map((data) => _convertMessage(data)).toList();
  }
  Future<TConversation> convCreate(String name,List<String> members,bool isUnique,Map attributes) async {
    var result = await _client.createConversation(name:name,members:members.toSet(),isUnique:isUnique,attributes:attributes);
    return _convertConversation(result);
  }
  Future convJoin(String conversationId) async {
    var conversation = await _getConversation(conversationId);
    await conversation.join();
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
  void onMessageReceived(TConversation conversation,TMessage message){
    if(message.msgType == SfMessageType.notify) return onNotifyReceived(message);
    saveConversation(conversation);
    saveMessage(message);
  }
  void onUnreadMessagesCountUpdated(TConversation conversation) {
    saveConversation(conversation);
  }
  void onNotifyReceived(TMessage message) => GetIt.instance<SfAppState>().addNotify(message.msgExtra['notifyType']);
  Future<Conversation> _getConversation(String conversationId) async {
    var query = _client.conversationQuery();
    query.whereString = jsonEncode({
      'objectId': conversationId,
    });
    query.limit = 1;
    var result = await query.find();
    if(result.length == 0) throw '未查询到会话!';
    return result[0];
  }
  Future<TMessage> _sendMessage(String conversationId,String msg,String msgType,Map msgExtra,{bool transient}) async {
    var conversation = await _getConversation(conversationId);
    var message = json.encode({
      'msg': msg,
      'msgType': msgType,
      'msgExtra': msgExtra
    });
    var result = await conversation.send(
      message: TextMessage.from(text:message),
      transient: transient??false
    );
    return _convertMessage(result);
  }
}