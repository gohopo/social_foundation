import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/services/locator_manager.dart';

abstract class SfConversation<TMessage extends SfMessage>{
  String convId;
  String? creator;
  Map dict;
  TMessage? lastMessage;
  int lastMessageAt;
  List members;
  String name;
  String ownerId;
  int top;
  int unreadMessagesCount;
  SfConversation(Map data)
  :convId=data['convId']??'',creator=data['creator'],dict=data['dict']??{},lastMessage=data['lastMessage'],lastMessageAt=data['lastMessageAt']??DateTime.now().millisecondsSinceEpoch
  ,members=data['members']??[],name=data['name']??'chat',ownerId=data['ownerId']??SfLocatorManager.userState.curUserId,top=data['top']??0,unreadMessagesCount=data['unreadMessagesCount']??0;
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['convId'] = convId;
    map['creator'] = creator;
    map['dict'] = jsonEncode(dict);
    map['lastMessage'] = lastMessage!=null ? json.encode(lastMessage?.toMap()) : null;
    map['lastMessageAt'] = lastMessageAt;
    map['members'] = json.encode(members);
    map['name'] = name;
    map['ownerId'] = ownerId;
    map['top'] = top;
    map['unreadMessagesCount'] = unreadMessagesCount;
    return map;
  }
  String? get otherId => type==0 ? members.firstWhereOrNull((userId) => userId!=ownerId) : null;
  /// 会话类型
  ///
  /// 0: 单聊
  /// 1: 群聊
  /// 2: 聊天室
  int get type => dict['__type']??0;
  void copyWith(SfConversation<TMessage> conversation){
    unreadMessagesCount = conversation.unreadMessagesCount;
    lastMessage = conversation.lastMessage;
    lastMessageAt = conversation.lastMessageAt;
  }
  Future delete() async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    await database.delete('conversation',where: 'ownerId=? and convId=?',whereArgs: [ownerId,convId]);
    SfLocatorManager.chatState.removeConversation(convId);
  }
  static Future deleteAll(String ownerId) async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    await database.delete('conversation',where: 'ownerId=?',whereArgs: [ownerId]);
    SfLocatorManager.chatState.removeAllConversations();
  }
  Future queryUnreadMessagesCount() async {
    var result = await SfLocatorManager.requestManager.invokeFunction('app', 'queryConversationUnreadCount', {
      'userId':ownerId,'convId':convId
    });
    unreadMessagesCount += result['count'] as int;
  }
  Future read() async {
    if(unreadMessagesCount==0) return;
    unreadMessagesCount = 0;
    await update(ownerId,convId,{'unreadMessagesCount':unreadMessagesCount});
    SfLocatorManager.chatState.updateConversation(this);
  }
  Future save();
  Future toggleTop() async {
    this.top = this.top==0 ? 1 : 0;
    await update(ownerId,convId,{'top':top});
    SfLocatorManager.chatState.updateConversation(this);
  }
  static Future update(String ownerId,String convId,Map<String,dynamic> data) async {
    var database = await SfLocatorManager.storageManager.getDatabase();
    return database.update('conversation',data,where:'ownerId=? and convId=?',whereArgs:[ownerId,convId]);
  }
}